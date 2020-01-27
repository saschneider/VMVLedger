#
# Spring configuration file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }
