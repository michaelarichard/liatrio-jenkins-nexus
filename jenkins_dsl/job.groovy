def gitURL = 'https://github.com/michaelarichard/liatrio-jenkins-nexus.git'
//def gitCreds = '826ff58e-40fb-46e0-bd91-2218a057b899' credential.xml ID
job('seed-job-1') {
    scm {
      git{
           remote {
              url(gitURL)
//	      credentials(gitCreds)
           }
	 }
    }
    triggers {
        scm('* * * * *')
    }
    steps {
        dsl {
	    external('**/*.groovy')
        }
    }
}
