#!/opt/rbenv/shims/ruby
# prints mostly used methods
# @ton31337 <donatas.abraitis@gmail.com>

require 'optparse'

options = {:count => 20,
           :refresh => 1,
           :sort => nil,
           :include => nil,
           :exclude => nil,
           :gt => 0,
           :path => "/opt/rbenv/versions/2.2.2/bin/ruby"}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: rubytop.rb [options]"

  opts.on('-g', '--greater <integer>', 'Filter if latency is greater than X ms') do |gt|
    options[:gt] = gt.to_i * 1000
  end

  opts.on('-e', '--exclude <string>', 'Exclude class') do |exclude|
    options[:exclude] = exclude
  end

  opts.on('-i', '--include <string>', 'Include only class') do |inc|
    options[:include] = inc
  end

  opts.on('-n', '--num <integer>', 'Show only X entries') do |count|
    options[:count] = count
  end

  opts.on('-p', '--path <string>', 'Ruby path') do |path|
    options[:path] = path
  end

  opts.on('-r', '--refresh <integer>', 'Refresh interval') do |refresh|
    options[:refresh] = refresh
  end

  opts.on('-s', '--sort_time', 'Sort by time') do |sort|
    options[:sort] = true
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end

end

parser.parse!

content = <<EOF
global calls;
global etimes;

@define SKIP(x,y) %( if(isinstr(@x, @y)) next; %)
@define ONLY(x,y) %( if(!isinstr(@x, @y)) next; %)

function print_head()
{
        ansi_clear_screen();
        printf("Probing...Type CTRL+C to stop probing.\\n");
}

function print_stats()
{
        foreach([tid, class, method, file, line, etime#{options[:sort] ? '-' : ''}] in calls#{options[:sort] ? '' : '-'} limit #{options[:count]}) {
                printf("<%d.%06d> tid:%-8d count:%-8d [%s#%s] %s:%d\\n",
                        (etime / 1000000), (etime % 1000000), tid, calls[tid, class, method, file, line, etime], class, method, file, line)
        }
}

probe process("#{options[:path]}").mark("method__entry")
{
        class = user_string($arg1);
        method = user_string($arg2);
EOF
content += <<EOF if options[:exclude]
        @SKIP(class, \"#{options[:exclude]}\");
EOF
content += <<EOF if options[:include]
        @ONLY(class, \"#{options[:include]}\");
EOF
content += <<EOF
        etimes[tid(), class, method] = gettimeofday_us();
}

probe process("#{options[:path]}").mark("method__return")
{
        class = user_string($arg1);
        method = user_string($arg2);
        file = user_string($arg3);
        line = $arg4;
EOF
content += <<EOF if options[:exclude]
        @SKIP(class, \"#{options[:exclude]}\");
EOF
content += <<EOF if options[:include]
        @ONLY(class, \"#{options[:include]}\");
EOF
content += <<EOF
        etime = gettimeofday_us() - etimes[tid(), class, method];
        if (!etimes[tid(), class, method] || etime < #{options[:gt]})
                next;

        calls[tid(), class, method, file, line, etime]++;
}

probe timer.s(#{options[:refresh]}) {
        print_head();
        print_stats();
        delete calls;
        delete etimes;
}
EOF

print "Compiling, please wait...\n"
IO.popen("echo '#{content}' | stap -DMAXMAPENTRIES=102400 -g --suppress-time-limits -") do |cmd|
  print $_ while cmd.gets
end
