##---------------------------------------------------------------------- 
##   Copyright 2010 Synopsys, Inc. 
##   All Rights Reserved Worldwide 
## 
##   Licensed under the Apache License, Version 2.0 (the 
##   "License"); you may not use this file except in 
##   compliance with the License.  You may obtain a copy of 
##   the License at 
## 
##       http://www.apache.org/licenses/LICENSE-2.0 
## 
##   Unless required by applicable law or agreed to in 
##   writing, software distributed under the License is 
##   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
##   CONDITIONS OF ANY KIND, either express or implied.  See 
##   the License for the specific language governing 
##   permissions and limitations under the License. 
##----------------------------------------------------------------------

#
# Simulator-Specific test running script
#
# Run a testcase using VCS
#

#
# Run the test implemented by the file named "test.sv" located
# in the specified directory.
#
# The specified directory must also be used as the CWD for the
# simulation run.
#
# Run silently, unless $opt_v is specified.
#
sub run_the_test {
  local($testdir, $_) = @_;

  $vcs = "vcs -sverilog -timescale=1ns/1ns +incdir+$uvm_home/src $uvm_home/src/uvm_pkg.sv test.sv -l vcs.log";
  $vcs .= " > /dev/null 2>&1" unless $opt_v;

  system("cd $testdir; rm -f simv; $vcs");

  if (-e "$testdir/simv") {
    $simv = "simv -l simv.log +UVM_TESTNAME=test";
    $simv .= " > /dev/null 2>&1" unless $opt_v;

    system("cd $testdir; $simv");
  }

  return 0;
}


#
# Return the name of the compile-time logfile
#
sub comptime_log_fname {
   return "vcs.log";
}


#
# Return the name of the run-time logfile
#
sub runtime_log_fname {
   return "simv.log";
}


#
# Return a list of filename & line numbers with compile-time errors
# for the test in the specified directory as an array, where each element
# is of the format "fname#lineno"
#
# e.g. ("test.sv#25" "test.sv#30")
#
sub get_compiletime_errors {
  local($testdir, $_) = @_;

  local($log);
  $log = "$testdir/vcs.log";
  if (!open(LOG, "<$log")) {
    return ();
  }

  local(@errs);

  while ($_ = <LOG>) {
    if (m/^Error-\[/) {
      $lf = <LOG>;
      if ($lf !~ m/^(\S+), (\d+)$/) {
	print STDERR "Invalid VCS compile-time error: \n$_$lf";
      } else {
	push(@errs, "$1#$2");
      }
    }
  }

  close(LOG);

  return @errs;
}


#
# Return a list of filename & line numbers with run-time errors
# for the test in the specified directory as an array, where each element
# is of the format "fname#lineno"
#
# e.g. ("test.sv#25" "test.sv#30")
#
# Run-time errors here refers to errors identified and reported by the
# simulator, not UVM run-time reports.
#
sub get_runtime_errors {
  local($testdir, $_) = @_;

  local($log);
  $log = "$testdir/simv.log";
  if (!open(LOG, "<$log")) {
    return ();
  }

  local(@errs);

  while ($_ = <LOG>) {
    if (m/^Error-\[/) {
      $lf = <LOG>;
      if ($lf !~ m/^(\S+), (\d+)$/) {
	print STDERR "Invalid VCS run-time error: \n$_$lf";
      } else {
	push(@errs, "$1#$2");
      }
    }
  }

  close(LOG);

  return @errs;
}


#
# Clean-up all files created by the simulation,
# except the log files
#
sub cleanup_test {
  local($testdir, $_) = @_;

  system("cd $testdir; rm -rf simv simv.daidir csrc ucli.* vc_hdrs.h .vcs*");
}

1;
