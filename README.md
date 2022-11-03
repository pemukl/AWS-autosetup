# AWS-autosetup
Scripts created in the realms of DSC102 at UCSD. Spins up four instances and one worker and automatically connects them into a cluster.

First, clone this repo by executing `git clone git@github.com:pemukl/AWS-autosetup.git` in a terminal. Change the directory by running `cd AWS-autosetup`.

Now, there are mainly two scripts you can run:
- `source launch.sh`: Spins up five instances on your AWS based on an existing template and starts setting them up with setup.sh .
- `source setup.sh`: Retrieves the ip adresses of your five instances and saves them to ips.txt. The first gets the sceduler and the other four are Workers. This can be run if you already have set up five instances on AWS.

On the respective instances setup_sceduler.sh and setup_worker.sh is run which starts the S3 download, the respective Dask demon and jupyter notebook. The workers are connected to the scheduler Further a tunnel from `localhost:8000` and `localhost:8001` is estabished to the jupyter notebook and the dask dashboard on the sceduler.

This requires serveral things in order to work:
- You must have set your AWS credentials, template ID and a ssh link to your private github repo in `config.sh`.
- Make sure the networking settings in the template are set correctly and the instances can communicate within each other in the template.
- Make sure your ssh agent knows your private key to access the EC2 instances. A tutorial for Mac can be found [here](https://www.howtogeek.com/devops/how-to-add-your-ec2-pem-file-to-your-ssh-keychain/).
- Make sure your ssh agent knows a private key for your github and forwards it. See a tutorial [here](https://docs.github.com/en/developers/overview/using-ssh-agent-forwarding).
- You must have installed [Byobu](https://www.byobu.org/) (thats an awesome terminal multiplexer. You can switch tabs by pressing "ctl+a" and then "n")
