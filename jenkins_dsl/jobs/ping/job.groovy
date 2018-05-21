job('ping') {
    parameters {
        stringParam('TARGET_HOST', '127.0.0.1', 'Name or IP of the Target Host to ping.')
    }
    steps {
        shell('''

		ping ${TARGET_HOST} -t1
		echo "Done."

	'''.stripIndent())
    }
}
