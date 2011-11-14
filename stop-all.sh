HOSTLIST=slaves
COMMAND="pkill -f fluentd"

for slave in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
    ssh $slave $COMMAND |sed "s/^/$slave: /"
    ssh $slave ps aux|grep fluentd |sed "s/^/$slave: /"
done

HOSTLIST=masters

for slave in `cat "$HOSTLIST"|sed  "s/#.*$//;/^$/d"`; do
    ssh $slave $COMMAND |sed "s/^/$slave: /"
    ssh $slave ps aux|grep fluentd |sed "s/^/$slave: /"
done

