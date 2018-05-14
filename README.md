1. Install and run this vagrant box: https://app.vagrantup.com/liatrio/boxes/jenkinsnexus/versions/0.0.1 (it's a relatively large file, it may take a little while to install)

2. Validate that both Jenkins and Nexus are installed on the VM.

3. Fork the spring-petclinic application to your own Github repository.

4. Modify the existing spring-petclinic jenkins job to point to your own repository.

5. Configure the spring-petclinic job to build on git code push.

6. Clone your spring-petclinic repository to your local machine.

7. Currently the build of the spring-petclinic does not deploy an artifact to Nexus - configure whatever is needed so that the build can successfully deploy to Nexus.

8. Review the maven dependencies of the spring-petclinic project. Choose one dependency and find the source code project on github.

9. Fork this repository to your own repository.

10. Create a Jenkins build job for this new project and make sure it will build and deploy to Nexus on git code push.

11. Configure the jenkins jobs to have an accurate upstream/downstream dependency on each other. 

12. Configure the spring-petclinic project to have a maven dependency on the new project, so that when a git push to the new project executes a successful build, it will automatically trigger a build of the spring-petclinic using this newly built artifact as the correct dependency. 

13. Wrap Up, Demo, Follow-Up
