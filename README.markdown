# Bounce Processor Hot Patch - Misclassified AOL Bounces

### Background

AOL started returning the following bounce message to some senders around September 2, 2015:

```
521 5.2.1 :  (CON:B1)  https://postmaster.aol.com/error-codes#554conb1
```

GreenArrow's bounce processor classified this as a hard bounce. However, the contents of the [URL shown in the bounce](https://postmaster.aol.com/error-codes#554conb1) indicate that the delivery attempt was blocked "due to a spike in recent complaints, poor reputation or policy reasons". In other words, these bounce would be more accurately classified as "Other bounces".

### Hot Patch Already Deployed

On March 23, 2016 DRH pushed a hot patch out to in support GreenArrow Engine installations. This hot patch updates GreenArrow's bounce processor to correclty classify these bounces.

There were a handful of installations that we were unable to hot patch on that day. We're contacting the owners of those installations directly to arrange to have the hot patch installed.

### This Hot Patch

The hot patch that we deployed on March 23 did not update the records of subscribers who had already been deactivated due to the bounce misclassification.

The repository contains code which can be used to reactivate these subscribers.

To calculate how many email addresses GreenArrow marked as bad due to this bounce, run:

```
echo "select count(1) from bounce_bad_addresses where type = 'h' and text like '%521 5.2.1 :  (CON:B1)  https://postmaster.aol.com/error-codes#554conb1'" | /var/hvmail/postgres/8.3/bin/psql -U greenarrow
```

To apply the hot patch, run:

```
bash -c "$( curl -fsSL 'https://raw.githubusercontent.com/drhinternet/aol_bounce_hot_patch/master/run.sh' )"
```
