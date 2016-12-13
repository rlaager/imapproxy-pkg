#! /bin/sh
# Initfile for imapproxy
#
### BEGIN INIT INFO
# Provides:          imapproxy
# Required-Start:    $syslog $network $local_fs $remote_fs
# Required-Stop:     $syslog $local_fs $remote_fs
# Should-Start:      $named courier-imap cyrus-imapd dovecot
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: IMAP proxy
# Description:       Proxy IMAP connections to reduce the load on backend servers
### END INIT INFO
#
# based upon skeleton by Miquel van Smoorenburg <miquels@cistron.nl>.
#	Modified for Debian GNU/Linux by Ian Murdock <imurdock@gnu.ai.mit.edu>.
#
# Version:	@(#)skeleton  1.8  03-Mar-1998  miquels@cistron.nl
# Customized for IMAP Proxy by Jose Luis Tallon <jltallon@adv-solutions.net>

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/imapproxyd
ARGS="-f /etc/imapproxy.conf"
NAME="imapproxy"
DESC="IMAP proxy"
PIDFILE="/var/run/$NAME.pid"
DEFAULT=/etc/default/$NAME

test -f $DAEMON || exit 0

# edit /etc/default/imapproxy to change this
START=yes

set -e

. /lib/lsb/init-functions

test -r ${DEFAULT} && . ${DEFAULT}
if [ "$START" = "no" -a "$1" != "stop" -a "$1" != "status" ]; then
	log_warning_msg "Not starting imapproxy - disabled in ${DEFAULT}";
	exit 0;
fi


case "$1" in
  start)
	if [ -f $PIDFILE ] && [ -e /proc/`cat $PIDFILE`/status ]; then
		echo "Already started: $NAME."
		exit 0
	fi
	echo -n "Starting $DESC: "
	start-stop-daemon --start --quiet --pidfile=$PIDFILE \
		--exec $DAEMON -- $ARGS
	sleep 1
	echo "$NAME."
	;;

  stop)
	if [ ! -f $PIDFILE ]; then
		echo "Not running: $NAME."
		exit 0
	fi
	if [ ! -e /proc/`cat $PIDFILE`/status ]; then
		rm -f $PIDFILE
		echo "Not running: $NAME."
		exit 0
	fi
	echo -n "Stopping $DESC: "
	start-stop-daemon --oknodo --stop --quiet --pidfile=$PIDFILE \
		--exec $DAEMON -- $ARGS 2>&1 | grep warning || true > /dev/null
	rm -f $PIDFILE
	echo "$NAME."
	;;

  restart|force-reload)
	echo "Restarting $DESC: "
	$0 stop
	sleep 2		# not gratuituous
	$0 start
	;;
  status)
	status_of_proc $DAEMON $NAME -p $PIDFILE
	;;
  *)
	N=/etc/init.d/$NAME
	# echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $N {start|stop|restart|force-reload|status}" >&2
	exit 1
	;;
esac

exit 0
