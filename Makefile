.PHONY: setup recon exploit post auto clean

setup:
	chmod +x scripts/**/*.sh 2>/dev/null || true

recon:
	cd scripts/recon && ./nmap.sh && ./gobuster.sh

exploit:
	cd scripts/exploit && ./upload_shell.sh

trigger:
	cd scripts/exploit && ./trigger_shell.sh

post:
	cd scripts/post && ./auto_post.sh 

report:
	cd scripts/report && ./show_reports.sh

clean:
	rm -rf reports/*

