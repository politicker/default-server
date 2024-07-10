set dotenv-load

ping:
	ansible default-server -m ping -i ansible/inventory.ini

ansible-preamble stage app:
	echo ansible-playbook \
		-i ansible/inventory.ini \
		-e @ansible/vars/{{ stage }}.yaml \
		--vault-password-file ansible/passwords \
		--force-handlers -v \
		--limit {{ stage }} \
		--tags {{ app }} \
		ansible/main.yaml

provision stage app:
	`just ansible-preamble {{ stage }} {{ app }}` \
		--skip-tags not-provision \
		--tags provision

# TODO: Consider moving betterbike main.go into cmd/main.go
compile app:
    cd $POLITICKER_DIR/{{ app }} && \
    GOOS=linux GOARCH=amd64 go build -o $POLITICKER_DIR/default-server/bin/{{ app }} .

deploy stage app:
    just compile {{ app }} && \
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
