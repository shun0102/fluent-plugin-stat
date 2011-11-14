MASTERS=masters
SLAVES=slaves

MASTER_CONF=~/work/fluent-plugin-stat/fluent-master.conf
SLAVE_CONF=~/work/fluent-plugin-stat/fluent-slave.conf
COMMAND="nohup fluentd -c"

for master in `cat "$MASTERS"|sed  "s/#.*$//;/^$/d"`; do
    ssh $master $COMMAND $MASTER_CONF &
done

for slave in `cat "$SLAVES"|sed  "s/#.*$//;/^$/d"`; do
    ssh $slave $COMMAND $SLAVE_CONF &
done
