###  **[Perl script to find the fastest FTP OpenBSD mirrors](http://bluepilltech.blogspot.com)**

**The Script**

This Perl script will get the FTP OpenBSD [mirrors list](http://ftp.openbsd.org/pub/OpenBSD/ftplist) from the OpenBSD FTP mirrors webpage, and parse through them via "ping" (TCP/80) to find the fastest mirror(s). The fastest mirros will be returned. The /etc/installurl file would be an ideal location to place the fastest mirror.


**Acknowledgement**

The script was found at http://bluepilltech.blogspot.com.
