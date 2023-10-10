# Java dump
Scripts to perform a memory dump from the Java virtual machine and collect information about threads, memory usage, environment and execution flags.
## javadump.sh
Used mainly from within Tomcat docker containers in case of memory leak or other memory/GC/heap related errors. The script retrieves the following information:
* PID of the main java process
* tomcat logs stored under /opt/tomcat/logs
* application logs stored under /opt/tomcat/webapps/.../WEB-INF/logs
* environment information such as execution flags, system properties and other virtual machine configurations
* classloader dump (available only for JDK > 8)
* metaspace dump (available only for JDK > 8)
* memory usage at the moment of the dump
* full JVM memory dump
* threads dump
## jvmmem.sh
A simple tool to monitor JVM memory usage. the script will automatically detect the PID of running java process and report min, max and used memory at the moment of the execution.<br>
For a continued monitoring run this command to pool the memory usage data every second: ```watch -n 1 ./jvmmem.sh```
