#!/bin/sh
file_path=./lib/fluent/plugin/in_stat.rb
fluentd_version=0.10.3
fluentd_path=~/.rvm/gems/ruby-1.9.2-p180/gems/fluentd-$fluentd_version/lib/fluent/plugin/

cp $file_path $fluentd_path
