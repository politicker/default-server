ping:
	ansible default-server -m ping -i ansible/inventory.ini

ansible-preamble stage app:
	echo ansible-playbook \
		-i ansible/inventory.ini \
		-e @ansible/vars/{{ stage }}.yaml \
		-e github_token=$(gh auth token) \
		--vault-password-file ansible/passwords \
		--force-handlers -v \
		--limit {{ stage }} \
		--tags {{ app }} \
		ansible/main.yaml

provision stage app:
	`just ansible-preamble {{ stage }} {{ app }}` \
		--skip-tags not-provision \
		--tags provision

deploy stage app:
	`just ansible-preamble {{ stage }} {{ app }}` \
		--skip-tags not-deploy \
		--tags deploy

encrypt +files:
	ansible-vault encrypt \
		--vault-password-file ansible/passwords \
		{{ files }}

edit file:
	ansible-vault edit \
		--vault-password-file ansible/passwords \
		{{ file }}

galaxy:
	ansible-galaxy install -r ansible/requirements.yaml --force
