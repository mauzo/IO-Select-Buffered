use Module::Build;

Module::Build->new(
    module_name		=> "IO::Select::Buffered",
    license		=> "bsd",
    requires            => {
        perl                => "5.8.1",
        parent              => 0,
        "Scalar::Util"      => "1.07",
    },
    configure_requires	=> {
	"Module::Build"	    => "0.38",
    },
    build_requires	=> {
	"Test::More"	    => "0.96",
    },
    meta_merge		=> {
	resources   => {
	    repository => "http://github.com/mauzo/IO-Select-Buffered",
	    bugtracker => "https://rt.cpan.org/Public/Dist/" .
		"Display.html?Name=IO-Select-Buffered",
	},
    },
)->create_build_script;
