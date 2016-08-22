#!/var/cfengine/bin/cf-agent -KIf

body common control
{
        inputs => {
                    "../lib/TAP.cf",
                    "../lib/common.cf",
                    "../lib/process_example.cf",
        } ;

        bundlesequence => { "test" } ;
}


bundle agent test
{
  vars:
      "init" string => "/sbin/init" ;
      "fake" string => "starvestone" ;

      "init_prefix" string => canonify("process $(init) running") ;
      "fake_prefix" string => canonify("process $(fake) running") ;

  classes:
      "has_init"
        expression => fileexists("$(init)"),
        scope => "namespace" ;

  methods:
      "plan" usebundle => tap_plan("3") ;

      "1" usebundle => tap_ok_if("1","has_init","system has init") ;

      "check_init" usebundle => check_process_running("$(init)") ;
      "2" usebundle => tap_result("2",
                                  "$(init_prefix)_ok",
                                  "$(init_prefix)_not_kept",
                                  "Check that init is running") ;

      "check_fake" usebundle  => check_process_running("$(fake)") ;
      "3" usebundle => tap_result("3",
                                  "$(fake_prefix)_not_kept",
                                  "$(fake_prefix)_ok",
                                  "Check that $(fake) is not running") ;
}
