<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	  "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
 <HEAD>
  <LINK REL="stylesheet" TYPE="text/css" HREF="//www.dnalounge.com/dnalounge.css?1">
  <TITLE>DNA Lounge</TITLE>
<!-- %%HEAD_START%% -->
  <STYLE TYPE="text/css">
<!--
  textarea {
   font-size: 10pt;
   line-height: 12pt;
   font-family: "Bitstream Vera Sans Mono", Menlo, "Courier New", Courier, monospace;
  }
-->
</STYLE>
<!-- %%HEAD_END%% -->
  <SCRIPT TYPE="text/javascript"><!--
   var _gaq = _gaq || [];
   _gaq.push(['_setAccount', 'UA-19982885-1']);
   _gaq.push(['_setDomainName', '.dnalounge.com']);
   _gaq.push(['_trackPageview']);
   (function() {
     var s = document.getElementsByTagName('script')[0];

     var ga = document.createElement('script');
     ga.type = 'text/javascript'; ga.async = true;
     ga.src = 'https://ssl.google-analytics.com/ga.js';
     s.parentNode.insertBefore(ga, s);

     ga = document.createElement('script');
     ga.type = 'text/javascript'; ga.async = true;
     ga.src = 'https://apis.google.com/js/plusone.js';
     s.parentNode.insertBefore(ga, s);
   })();
   //-->
  </SCRIPT>
  <META NAME="geo.position" CONTENT="37.771007;-122.412694">
  <META NAME="viewport" CONTENT="width=device-width">
  <LINK REL="shortcut icon" HREF="/favicon.ico" TYPE="image/x-icon">
  <LINK REL="top"   HREF="//www.dnalounge.com/">
  <LINK REL="up"    HREF="../">
  <LINK REL="menubase" HREF="//www.dnalounge.com/">
 </HEAD>
 <BODY>
  <DIV CLASS="page">
   <DIV CLASS="top">
<!-- %%MENU_START%% -->
   <DIV CLASS="masthead"><A HREF="//www.dnalounge.com/"><IMG SRC="//www.dnalounge.com/logo.gif"></A></DIV>
   <UL CLASS="menu" ID="menu1"><LI>
    <A HREF="//www.dnalounge.com/./">Home</A>
    </LI><LI><A HREF="//www.dnalounge.com/calendar/latest.html">Calendar</A>
    </LI><LI><A HREF="//www.dnalounge.com/directions/">Directions</A>
    </LI><LI><A HREF="//www.dnalounge.com/tickets/">Tickets</A>
    </LI><LI><A HREF="//www.dnalounge.com/webcast/">Webcasts</A>
    </LI><LI><A HREF="//www.dnalounge.com/contact/">Contact</A>
   </LI></UL>
<!-- %%MENU_END%% -->
   </DIV>
   <DIV CLASS="bottom">
<!-- %%BOTTOM_START%% -->
<!-- %%HEADING%% -->
<DIV ALIGN=CENTER><B CLASS="gwbox">Snark-a-Tron: Promoter Messages</B></DIV><P>

<FORM METHOD="POST" NAME="snarkform">
 <P>
 <DIV ALIGN=CENTER>
  [@-- $status --@]
 </DIV>

 <P> This page is used to update up to four messages which will stay in
 the sign's message loop until the end of the night. Messages will
 self-destruct at 6am, the following day.

 <P> To remove a message: remove all the text in the message box (or
 click the "Clear All" button) and then press "Update".  Blank messages
 will not be displayed on the sign.

 <DIV ALIGN=CENTER>

  <DIV CLASS="box">
   <TABLE BORDER=0 CELLPADDING=2 CELLSPACING=0>
    <TR>
     <TD NOWRAP VALIGN=TOP>
      Message 1:<br>
      <TEXTAREA NAME="message0" COLS=31 ROWS=4 WRAP=SOFT>[@--$message0--@]</TEXTAREA>
      <P>
      Message 2:<br>
      <TEXTAREA NAME="message1" COLS=31 ROWS=4 WRAP=SOFT>[@--$message1--@]</TEXTAREA>
      <P>
      Message 3:<br>
      <TEXTAREA NAME="message2" COLS=31 ROWS=4 WRAP=SOFT>[@--$message2--@]</TEXTAREA>
      <P>
      Message 4:<br>
       <TEXTAREA NAME="message3" COLS=31 ROWS=4 WRAP=SOFT>[@--$message3--@]</TEXTAREA>
      <P>
      <DIV ALIGN=LEFT>
       [@--$permitpub--@]<BR>
       &nbsp; &nbsp; &nbsp;
       (resets at 6AM to <I>yes.</I>)
      </DIV>

      <P>

      <DIV ALIGN=CENTER>
       <INPUT NAME="Clear All" TYPE=RESET VALUE="Clear All"
             ONCLICK='document.snarkform.message0.value="";
                      document.snarkform.message1.value="";
                      document.snarkform.message2.value="";
                      document.snarkform.message3.value="";
                      return false;'>
       &nbsp; &nbsp; &nbsp; 
       <INPUT NAME="Update" TYPE=SUBMIT VALUE="Update">
      </DIV>
     </TD>
    </TR>
   </TABLE>
  </DIV>

  <P>

  Special codes you can use in your message:

  <P>
  <TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0>
   <TR>
    <TD NOWRAP STYLE="color:F00">%%R&nbsp; Red</TD>
    <TD NOWRAP WIDTH=30></TD>
    <TD NOWRAP>%%X&nbsp; <SPAN STYLE="background:#0F0">&nbsp;&nbsp;</SPAN> &nbsp;(Box)</TD>
   </TR>
   <TR>
    <TD NOWRAP STYLE="color:0F0">%%G&nbsp; Green</TD>
    <TD></TD>
    <TD NOWRAP>%%B&nbsp; Blink</TD>
   </TR>
   <TR>
    <TD STYLE="color:FFF833">%%A&nbsp; Amber</TD>
    <TD></TD>
    <TD NOWRAP>%%E&nbsp; Blink off</TD>
   </TR>
  </TABLE>

  <P>

  <DIV CLASS="box">
   <TABLE BORDER=0 CELLPADDING=4 CELLSPACING=0>
    <TR>
     <TD VALIGN=TOP NOWRAP>
      <INPUT TYPE="SUBMIT" NAME="emergency" VALUE="CLEAR PUBLIC POSTS"></TD>
     <TD VALIGN=TOP>
      Click here to remove all public posts,<BR>and turn posting off.
     </TD>
    </TR>
    <TR>
     <TD VALIGN=TOP NOWRAP>
      <INPUT TYPE="SUBMIT" NAME="turnoff" VALUE="TURN OFF"></TD>
     <TD VALIGN=TOP>
      Click here to turn the sign completely off
     </TD>
    </TR>
    <TR>
     <TD VALIGN=TOP NOWRAP>
      <INPUT TYPE="SUBMIT" NAME="turnon" VALUE="TURN ON"></TD>
     <TD VALIGN=TOP>
      Click here to turn the sign on<BR>with public posts allowed
     </TD>
    </TR>
    <TR> 
     <TD></TD>
     <TD VALIGN=TOP ALIGN=LEFT> 
     Sign is currently <B>[@--$pwrstat--@].</B>
     </TD>
    </TR>
   </TABLE>
  </DIV>

 </DIV>
</FORM>
<P>
<!-- %%BOTTOM_END%% -->
   </DIV>
  </DIV>
 </BODY>
</HTML>
