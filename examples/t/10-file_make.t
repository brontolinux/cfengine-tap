#!/var/cfengine/bin/cf-agent -KIf

body common control
{
        inputs => {
                    "../lib/TAP.cf",
                    "../lib/files.cf",
        } ;

        bundlesequence => { test } ;
}

bundle agent test
{
  vars:
      "file"    string => "$(this.promise_dirname)/file_make.testfile" ;
      "content" string => "file_make test content" ;

  methods:
      "1" usebundle => check_file_absent("1","$(file)") ;

      "make_file" usebundle => file_make("$(file)","$(content)") ;
      "2" usebundle => check_file_present("2","$(file)") ;

      "3" usebundle => check_file_content("3","$(file)","$(content)") ;

      "tidy" usebundle => file_tidy("$(file)") ;
      "4" usebundle => check_file_absent("4","$(file)") ;

      "plan" usebundle => tap_plan("4") ;
}


bundle agent check_file_absent(n,file)
{
  classes:
      "file_absent"
        not => fileexists("$(file)"),
        scope => "namespace",
        comment => "Mind the scope, or it will fail!" ;

  methods:
      "test" usebundle => tap_ok_if("$(n)","file_absent",
                                    "File $(file) is absent") ;
}


bundle agent check_file_present(n,file)
{
  classes:
      "file_present" expression => fileexists("$(file)"),
        scope => "namespace",
        comment => "Mind the scope, or it will fail!" ;

  methods:
      "test" usebundle => tap_ok_if("$(n)","file_present",
                                    "File $(file) is present") ;
}


bundle agent check_file_content(n,file,content)
{
  vars:
      "content_read" string => readfile("$(file)",1024) ;

  classes:
      "file_content_ok"
        expression => regcmp("\Q$(content_read)\E","$(content)"),
        scope => "namespace",
        comment => "Compare the expected content with the actual one" ;

  methods:
      "test" usebundle => tap_ok_if("$(n)","file_content_ok",
                                    "File $(file) has the expected content") ;
}
