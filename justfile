set dotenv-load

ping:
	ansible default-server -m ping -i ansible/inventory.ini

ansible-preamble app:
	echo ansible-playbook \
		-i ansible/inventory.ini \
		--vault-password-file ansible/passwords \
		--force-handlers -v \
		--tags {{ app }} \
		ansible/main.yaml

provision app:
	`just ansible-preamble {{ app }}` \
		--skip-tags not-provision \
		--tags provision

compile app:
		cd $POLITICKER_DIR/{{ app }}/cmd && \
		GOOS=linux GOARCH=amd64 go build -o $POLITICKER_DIR/default-server/ansible/files/bin/{{ app }} .

deploy app:
	just compile {{ app }} && \
	`just ansible-preamble {{ app }}` \
		--skip-tags not-deploy \
		--tags deploy

caddy:
	`just ansible-preamble caddy` \
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
