module.exports = function(grunt) {

    // Time how long tasks take. Can help when optimizing build times
    require('time-grunt')(grunt);

    // Automatically load required grunt tasks
    require('jit-grunt')(grunt);

    var init_config = {

        config: grunt.file.readJSON('gruntconfig.json'),

        clean: {
            build: {
                files: [{
                    dot: true,
                    src: [
                        './dist'
                    ]
                }]
            }
        },

        copy: {
            build: {
                files: [{ expand: true, cwd: 'src/', src: ['**'], dest: './dist' }]
            }
        },

        replace: {
            import_paths: {
                options: {
                    patterns: [{
                        match: /(\$path = \$_SERVER\['DOCUMENT_ROOT']\s*\.\s*)"\/.*?";/,
                        replacement: '$1"/<%= config.server_dir %>";'
                    }]
                },
                files: [
                    { cwd: './dist', expand: true, src: ['**/*.php'], dest: './dist' }
                ]
            },
            site_url: {
                options: {
                    patterns: [{
                        match: /(\$SITE_URL\s*?=\s)[\s\S]*?;/,
                        replacement: '$1"https://<%= config.site_url %><%= config.site_dir %>";'
                    }]
                },
                files: [
                    { cwd: './dist', expand: true, src: ['config/constants.php'], dest: './dist' }
                ]
            },
            mail_settings: {
                options: {
                    patterns: [{
                            match: /(\$MAIL_ACCOUNT\s*?=\s)[\s\S]*?;/,
                            replacement: '$1"<%= config.mail_account %>";'
                        },
                        {
                            match: /(\$MAIL_PASSWORD\s*?=\s)[\s\S]*?;/,
                            replacement: '$1"<%= config.mail_password %>";'
                        },
                        {
                            match: /(\$MAIL_HOST\s*?=\s)[\s\S]*?;/,
                            replacement: '$1"<%= config.mail_host %>";'
                        },
                        {
                            match: /(\$MAIL_PORT\s*?=\s)[\s\S]*?;/,
                            replacement: '$1"<%= config.mail_port %>";'
                        }
                    ]
                },
                files: [
                    { cwd: './dist', expand: true, src: ['config/constants.php'], dest: './dist' }
                ]
            },
            db_config: {
                options: {
                    patterns: [{
                            match: /("DB_HOST"\s*?=>\s*?)"[\s\S]*?,/,
                            replacement: '$1"localhost",'
                        },
                        {
                            match: /("DB_NAME"\s*?=>\s*?)"[\s\S]*?,/,
                            replacement: '$1"<%= config.db_name %>",'
                        },
                        {
                            match: /("DB_USER"\s*?=>\s*?)"[\s\S]*?,/,
                            replacement: '$1"<%= config.db_user %>",'
                        },
                        {
                            match: /("DB_PASS"\s*?=>\s*?)"[\s\S]*?"/,
                            replacement: '$1"<%= config.db_pass %>"'
                        }
                    ]
                },
                files: [
                    { cwd: './dist', expand: true, src: ['config/config.inc.php'], dest: './dist' }
                ]
            },
            no_mails: {
                options: {
                    patterns: [{
                        match: /(\$mail->send\(\);)/g,
                        replacement: '\/\/$1'
                    }]
                },
                files: [
                    { cwd: './dist', expand: true, src: ['classes/Mailer.class.php'], dest: './dist' }
                ]
            }
        }
    };

    grunt.initConfig(init_config);

    grunt.registerTask('get-local-ip', 'Get IP Address for LAN.', function() {
        var os = require('os'),
            ifaces = os.networkInterfaces(),
            lookupIpAddress = null,
            devices = ["enl", "en0", "WiFi", "Ethernet"];

        for (var dev in ifaces) {
            if (devices.indexOf(dev) === -1)
                continue;

            ifaces[dev].some(function(details) {
                if (details.family == 'IPv4') {
                    lookupIpAddress = details.address;
                    return true;
                }
            });
        }

        grunt.log.writeln("Local IP Address found: " + lookupIpAddress);
        var old_config = grunt.config.get("config"),
            new_config = old_config.site_url = lookupIpAddress;
        grunt.config.set('config.site_url', lookupIpAddress);
    });

    function runTasks(name) {
        grunt.config('config', grunt.file.readJSON('gruntconfig.json')[name]);

        var tasks = [];

        tasks.push('clean:build');

        if (name === "local")
            tasks.push('get-local-ip');

        tasks.push('copy:build');
        tasks.push('replace:import_paths');

        if (name === "local" || name === "preprod")
            tasks.push('replace:no_mails');

        tasks.push('replace:mail_settings');
        tasks.push('replace:db_config');
        tasks.push('replace:site_url');

        grunt.task.run(tasks);
    }

    grunt.registerTask('local', function() {
        runTasks("local");
    });

    grunt.registerTask('preprod', function() {
        runTasks("preprod");
    });

    grunt.registerTask('prod', function() {
        runTasks("prod");
    });
};