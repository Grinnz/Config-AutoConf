use strict;
use warnings;
use ExtUtils::MakeMaker;

my %RUN_DEPS = (
    'base'             => 0,
    'strict'           => 0,
    'warnings'         => 0,
    'Carp'             => 0,
    'Capture::Tiny'    => 0,
    'Config'           => 0,
    'Cwd'              => 0,
    'Exporter'         => 0,
    'File::Basename'   => 0,
    'File::Spec'       => 0,
    'File::Temp'       => 0,
    'Text::ParseWords' => 0,
);
my %CONFIGURE_DEPS = ('ExtUtils::MakeMaker' => 0);
my %BUILD_DEPS = ();

my %TEST_DEPS = (
    'Test::More'         => 0.90,
    'ExtUtils::CBuilder' => '0.23'
);
$] < 5.008 and $TEST_DEPS{'IO::String'} = 0;

WriteMakefile1(
    META_ADD => {
        'meta-spec' => {version => 2},
        resources   => {
            homepage   => 'https://metacpan.org/release/Config-AutoConf',
            repository => {
                url  => 'https://github.com:ambs/Config-AutoConf.git',
                web  => 'https://github.com/ambs/Config-AutoConf',
                type => 'git',
            },
            license    => 'http://dev.perl.org/licenses/',
            bugtracker => {
                web    => 'http://rt.cpan.org/Public/Dist/Display.html?Name=Config-AutoConf',
                mailto => 'bug-Config-AutoConf@rt.cpan.org',
            },
            x_IRC         => "irc://irc.perl.org/#toolchain",
            x_MailingList => "mailto:cpan-workers\@perl.org'",
        },
        prereqs => {
            develop => {
                requires => {
                    'Test::CPAN::Changes'                 => 0,
                    'Test::CheckManifest'                 => 0,
                    'Module::CPANTS::Analyse'             => '0.96',
                    'Test::Kwalitee'                      => 0,
                    'Test::PerlTidy'                      => 0,
                    'Test::Pod'                           => 0,
                    'Test::Pod::Coverage'                 => 0,
                    'Test::Pod::Spelling::CommonMistakes' => 0,
                    'Test::Spelling'                      => 0,
                },
            },
            configure => {
                requires => {%CONFIGURE_DEPS},
            },
            build => {
                requires => {%BUILD_DEPS},
            },
            test => {
                requires => {%TEST_DEPS},
            },
            runtime => {
                requires   => {%RUN_DEPS},
                recommends => {
                    'ExtUtils::CBuilder' => '0.280220',
                    'File::Slurp::Tiny'  => 0,
                    'Scalar::Util'       => '1.18',
                },
            },
        },
    },
    NAME           => 'Config::AutoConf',
    AUTHOR         => ['Alberto Simoes <ambs@cpan.org>', 'Jens Rehsack <rehsack@cpan.org'],
    VERSION_FROM   => 'lib/Config/AutoConf.pm',
    ABSTRACT_FROM  => 'lib/Config/AutoConf.pm',
    LICENSE        => 'perl',
    PREREQ_PM      => \%RUN_DEPS,
    BUILD_REQUIRES => \%BUILD_DEPS,
    TEST_REQUIRES  => \%TEST_DEPS,
    test           => {TESTS => 't/*.t xt/*.t'},
);

sub WriteMakefile1
{    # originally written by Alexandr Ciornii, version 0.21. Added by eumm-upgrade.
    my %params       = @_;
    my $eumm_version = $ExtUtils::MakeMaker::VERSION;
    $eumm_version = eval $eumm_version;
    die "EXTRA_META is deprecated" if (exists($params{EXTRA_META}));
    die "License not specified"    if (!exists($params{LICENSE}));
    $params{TEST_REQUIRES}
      and $eumm_version < 6.6303
      and $params{BUILD_REQUIRES} = {%{$params{BUILD_REQUIRES} || {}}, %{delete $params{TEST_REQUIRES}}};
    #EUMM 6.5502 has problems with BUILD_REQUIRES
    $params{BUILD_REQUIRES}
      and $eumm_version < 6.5503
      and $params{PREREQ_PM} = {%{$params{PREREQ_PM} || {}}, %{delete $params{BUILD_REQUIRES}}};
    ref $params{AUTHOR}
      and "ARRAY" eq ref $params{AUTHOR}
      and $eumm_version < 6.5702
      and $params{AUTHOR} = join(", ", @{$params{AUTHOR}});
    delete $params{CONFIGURE_REQUIRES}    if ($eumm_version < 6.52);
    delete $params{MIN_PERL_VERSION}      if ($eumm_version < 6.48);
    delete $params{META_MERGE}            if ($eumm_version < 6.46);
    delete $params{META_ADD}{prereqs}     if ($eumm_version < 6.58);
    delete $params{META_ADD}{'meta-spec'} if ($eumm_version < 6.58);
    delete $params{META_ADD}              if ($eumm_version < 6.46);
    delete $params{LICENSE}               if ($eumm_version < 6.31);
    delete $params{AUTHOR}                if ($] < 5.005);
    delete $params{ABSTRACT_FROM}         if ($] < 5.005);
    delete $params{BINARY_LOCATION}       if ($] < 5.005);

    # more or less taken from Moose' Makefile.PL
    if ($params{CONFLICTS})
    {
        my $ok = CheckConflicts(%params);
        exit(0) if ($params{PREREQ_FATAL} and not $ok);
        my $cpan_smoker = grep { $_ =~ m/(?:CR_SMOKER|CPAN_REPORTER|AUTOMATED_TESTING)/ } keys %ENV;
        unless ($cpan_smoker || $ENV{PERL_MM_USE_DEFAULT})
        {
            sleep 4 unless ($ok);
        }
        delete $params{CONFLICTS};
    }

    WriteMakefile(%params);
}
