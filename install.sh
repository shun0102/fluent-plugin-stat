#!/bin/sh
file_path=./lib/fluent/plugin/*
fluentd_version=0.10.7
fluentd_path=~/.rvm/gems/ruby-1.9.2-p290/gems/fluentd-$fluentd_version/lib/fluent/plugin/

cp $file_path $fluentd_path
