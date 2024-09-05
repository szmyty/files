Docker containers, by default, have a reduced set of capabilities when compared to the host machine. Here is a list of all the Linux capabilities that you can manage using Docker’s cap_add and cap_drop settings:

1. **CAP_AUDIT_CONTROL** - Enable and disable kernel auditing; change auditing filter rules; retrieve auditing status and filtering rules.
2. **CAP_AUDIT_READ** - Allow reading the audit log via multicast netlink socket.
3. **CAP_AUDIT_WRITE** - Write records to kernel auditing log.
4. **CAP_BLOCK_SUSPEND** - Block system suspends.
5. **CAP_CHOWN** - Make arbitrary changes to file UIDs and GIDs (see chown(2)).
6. **CAP_DAC_OVERRIDE** - Bypass file read, write, and execute permission checks.
7. **CAP_DAC_READ_SEARCH** - Bypass file read permission checks and directory read and execute permission checks.
8. **CAP_FOWNER** - Bypass permission checks on operations that normally require the file system UID of the process to match the UID of the file.
9. **CAP_FSETID** - Don’t clear set-user-ID and set-group-ID permission bits when a file is modified.
10. **CAP_IPC_LOCK** - Lock memory (mlock, mlockall, mmap, shmctl).
11. **CAP_IPC_OWNER** - Bypass permission checks for operations on System V IPC objects.
12. **CAP_KILL** - Bypass permission checks for sending signals.
13. **CAP_LEASE** - Establish leases on arbitrary files (see fcntl(2)).
14. **CAP_LINUX_IMMUTABLE** - Set the FS_APPEND_FL and FS_IMMUTABLE_FL i-node flags.
15. **CAP_MAC_ADMIN** - Allow MAC configuration or state changes. Implemented for the Smack LSM.
16. **CAP_MAC_OVERRIDE** - Override Mandatory Access Control (MAC).
17. **CAP_MKNOD** - Create special files using mknod(2).
18. **CAP_NET_ADMIN** - Perform various network-related operations.
19. **CAP_NET_BIND_SERVICE** - Bind a socket to internet domain privileged ports (port numbers less than 1024).
20. **CAP_NET_BROADCAST** - (Unused) Make socket broadcasts, and listen to multicasts.
21. **CAP_NET_RAW** - Use RAW and PACKET sockets.
22. **CAP_SETGID** - Make arbitrary manipulations of process GIDs and supplementary GID list.
23. **CAP_SETPCAP** - Transfer or remove any capability in your permitted set to or from any other process.
24. **CAP_SETFCAP** - Set file capabilities.
25. **CAP_SETPCAP** - Modify process capabilities.
26. **CAP_SETUID** - Make arbitrary manipulations of process UIDs.
27. **CAP_SYS_ADMIN** - Perform a range of system administration operations.
28. **CAP_SYS_BOOT** - Use reboot(2) and kexec_load(2), reboot and load a new kernel for later execution.
29. **CAP_SYS_CHROOT** - Use chroot(2), change root directory.
30. **CAP_SYS_MODULE** - Load and unload kernel modules.
31. **CAP_SYS_NICE** - Raise process nice value (nice(2), setpriority(2)) and change the nice value for other processes.
32. **CAP_SYS_PACCT** - Use acct(2), switch process accounting on or off.
33. **CAP_SYS_PTRACE** - Trace arbitrary processes using ptrace.
34. **CAP_SYS_RAWIO** - Perform I/O port operations (iopl(2) and ioperm(2)).
35. **CAP_SYS_RESOURCE** - Override resource limits. Set resource limits.
36. **CAP_SYS_TIME** - Set system clock (settimeofday, stime, adjtimex); set real-time (hardware) clock.
37. **CAP_SYS_TTY_CONFIG** - Use vhangup(2); use various privileged ioctl(2) operations on virtual terminals.
38. **CAP_SYSLOG** - Perform privileged syslog(2) operations.
39. **CAP_WAKE_ALARM** - Trigger something that will wake up the system.

These capabilities allow for fine-grained access control over various system resources and actions. By understanding and appropriately setting these capabilities, you can minimize the potential attack surface of your Docker containers, enhancing their security.

[Reference for Docker capabilities](https://docs.docker.com/engine/security/security/#linux-kernel-capabilities)
