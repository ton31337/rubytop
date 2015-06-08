rubytop.rb
==============

### Before usage

rbenv:
```
yum install systemtap systemtap-runtime systemtap-sdt-devel kernel-devel kernel-debuginfo -y
CONFIGURE_OPTS="--enable-dtrace" rbenv install 2.2.2
```

repo ruby:
```
yum install ruby systemtap systemtap-runtime systemtap-sdt-devel kernel-devel kernel-debuginfo -y
```

rvm:
```
yum install systemtap systemtap-runtime systemtap-sdt-devel kernel-devel kernel-debuginfo -y
rvm install 2.2.2 --enable-dtrace
```

P.S. tested only on CentOS 6.x, 7.x

### Usage
```
$ /root/bin/rubytop.rb -h
Usage: rubytop.rb [options]
    -g, --greater <integer>          Filter if latency is greater than X ms
    -e, --exclude <string>           Exclude class
    -i, --include <string>           Include only class
    -n, --num <integer>              Show only X entries
    -p, --path <string>              Ruby path
    -r, --refresh <integer>          Refresh interval
    -s, --sort_time                  Sort by time
    -h, --help                       Displays Help
```

### Example
```
$ /root/bin/rubytop.rb -r 3 -n 20 -g 20 -i Catalog
Compiling, please wait...
Probing...Type CTRL+C to stop probing.
<0.023239> tid:26779    count:2        [Catalog#parent_ids] /opt/../catalog.rb:331
<0.264188> tid:26779    count:1        [Catalog#localize] /opt/../catalog.rb:315
```
