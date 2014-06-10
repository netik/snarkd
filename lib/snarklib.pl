#
# snarklib - often-used functions for the snarkatron
#

use POSIX;

sub isLeapYear {
  my $year=shift;

  # divisible by 4
  $isLeapYear = ($year % 4 == 0);
  
  # divisible by 4 and not 100
  $isLeapYear = $isLeapYear && ($year % 100 != 0);
  
  # divisible by 4 and not 100 unless divisible by 400
  $isLeapYear = $isLeapYear || ($year % 400 == 0);

  return $isLeapYear;
}

# Given a string of Snark control codes (%%G, %%X, \\n, etc.)
# wraps the text to 32 columns and returns the new string.
# Wrapping is smart enough to ignore control codes that do not
# consume character positions.
#
# Returns undef if the message is too large after wrapping.
#
sub snark_wrap($$;$) {
  my ($msg, $center, $truncate_p) = @_;

  $msg =~ s/\\n/\n/g;
  $msg =~ s/\s+$//s;

  my $text = '';   # text only
  my $meta = '';   # metadata

  my $current_color = 'G';
  my $blinking_p = 0;

  foreach my $c (split(m/(%%[RGAXBE]|.)/s, $msg)) {
    next if ($c eq '');

    if    ($c eq '%%R') { $current_color = 'R'; next; }
    elsif ($c eq '%%G') { $current_color = 'G'; next; }
    elsif ($c eq '%%A') { $current_color = 'A'; next; }
    elsif ($c eq '%%B') { $blinking_p = 1; next; }
    elsif ($c eq '%%E') { $blinking_p = 0; next; }
    elsif ($c eq '%%X') { $c = "\377"; }
    elsif ($c eq "\n")  { $blinking_p = 0;	# newlines end blink & color
                          $current_color = 'G'; }

    my $m = (($c =~ m/^[ \t\r\n]$/)
             ? $c
             : ($blinking_p ? uc($current_color) : lc($current_color)));
    $text .= $c;
    $meta .= $m;
  }
  
  $Text::Wrap::columns = 32;
  $Text::Wrap::unexpand = 0;   # no tabs

  # wrap each line in $text and $meta independently: treat newlines as hard.
  {
    my $t2 = '';
    foreach my $line (split ("\n", $text)) {
      $t2 .= Text::Wrap::wrap ('', '', $line) . "\n";
    }
    my $m2 = '';
    foreach my $line (split ("\n", $meta)) {
      $m2 .= Text::Wrap::wrap ('', '', $line) . "\n";
    }
    $text = $t2;
    $meta = $m2;
  }

  if (length ($text) != length ($meta)) {
    die "internal error: text and meta wrapped differently\n";
  }


  # Center each line, if desired.
  #
  if ($center) {
    my $t2 = '';
    my $m2 = '';

    foreach my $line (split ("\n", $text)) {
      $line =~ s/(^[ \t]+|[ \t]+$)//gs;
      my $n = int (($Text::Wrap::columns - length($line)) / 2);
      $t2 .= (' ' x $n) . $line . "\n";
    }
    foreach my $line (split ("\n", $meta)) {
      $line =~ s/(^[ \t]+|[ \t]+$)//gs;
      my $n = int (($Text::Wrap::columns - length($line)) / 2);
      $m2 .= (' ' x $n) . $line . "\n";
    }
    $text = $t2;
    $meta = $m2;
  }


  # We have wrapped the text, without letting the escape codes interfere
  # with column positioning.  Now re-construct the string with escape codes.

  my @text = split(//, $text);
  my @meta = split(//, $meta);
  my $result = '';

  $current_color = 'G';
  $blinking_p = 0;

  while ($#text >= 0) {
    my $c = shift @text;
    my $m = shift @meta;

    # fortunately the sign doesn't blink or color spaces in any way.
    if ($c =~ m/^[ \t\r\n]$/) {
      if ($c ne $m) {
        die "internal error: text/meta whitespace mismatch\n";
      }
      $result .= $c;
      if ($c eq "\n") {        # newlines implicitly turn off blink/color
        $current_color = 'G';
        $blinking_p = 0;
      }
      next;
    }

    my $this_color = uc($m);
    my $this_blink = ($m =~ m/^[A-Z]$/);

    if ($this_color ne $current_color) {
      if    ($this_color eq 'R') { $result .= '%%R'; }
      elsif ($this_color eq 'G') { $result .= '%%G'; }
      elsif ($this_color eq 'A') { $result .= '%%A'; }
      else { die "internal error: bogus color $this_color\n"; }

      $current_color = $this_color;
    }

    if ($this_blink != $blinking_p) {
      $result .= ($this_blink ? '%%B' : '%%E');
      $blinking_p = $this_blink;
    }

    if ($c eq "\377") { $c = '%%X'; }

    $result .= $c;
  }

  $result =~ s/[ \t]+$//gm;  # lose line-ending spaces
  $result =~ s/\s+$//s;      # lose trailing newlines

  {
    my $raw = $result;
    $raw =~ s/%%X/_/gs;
    $raw =~ s/%%.//gs;
    if (length ($raw) > 132) {

      if (! $truncate_p) {
        return undef;  # message too big
      } else {
        # This is hokey, but so what.  Remove "characters" from the end
        # until it's short enough.

        do {
          $result =~ s/\s+$//s;
          $result =~ s/(%%.|.)$//s;
          $raw = $result;
          $raw =~ s/%%X/_/gs;
          $raw =~ s/%%.//gs;
        } while (length ($raw) > 132);
      }
    }
  }

  my @lines = split("\n", $result);
  if ($#lines > 3) {
    if (! $truncate_p) {
      return undef;  # message too big
    } else {
      @lines = @lines[0 .. 3];
      $result = join("\n", @lines);
    }
  }

  # always center vertically: if the message is 1 or 2 lines long, 
  # insert a leading blank line.
  #
  if ($#lines <= 1) { $result = "\n$result"; }

  # #### Bah, work around the bug that the ini file throws away leading spaces.
  # If we can move the %% code to the beginning of the line (moving it to
  # before the whitespace instead of after) then do so.  Otherwise, if the
  # line begins with a space, stick a no-op (in this case, %%G) on the front.
  #
  $result =~ s/^( +)(%%[RGABE])/$2$1/s;  # not %%X
  $result =~ s/^ /%%G /s;

  # Quote newlines.  This is dumb, but it's all over the code.
  $result =~ s/\n/\\n/gs;

  return $result;
}


sub get_time() {
  my $s = strftime ("%r", localtime);
  $s =~ s/^0//s;
  return $s;
}


sub get_date() {
  return strftime ("%a, %e %b", localtime);
}

# Converts a message string to HTML.
# Assumes caller will display it inside a <PRE>.
#
sub formatmsg_ashtml($) {
  my ($str) = @_;

  $str =~ s/%%T/{ get_time() }/eg;
  $str =~ s/%%D/{ get_date() }/eg;

  $str =~ s/\\n/\n/gs;

  my $current_color = '';
  my $blinking_p = 0;

  # in case HTML reserved chars made it in somehow...
  $str =~ s/&/&amp;/g;
  $str =~ s/</&lt;/g;
  $str =~ s/>/&gt;/g;

  $str =~ s/^( *)%%G/$1/s;    # remove no-op "green" at beginning of line.

  my $out = '';
  foreach my $c (split(m/(%%[RGAXBE]|.)/s, $str)) {
    next if ($c eq '');

    if ($c =~ m/^%%[RGA]$/s) {
      $out .= '</BLINK>' if ($blinking_p);       # blink always inside span
      $out .= '</SPAN>' if ($current_color);
      $current_color = ($c =~ '%%R' ? '#F00' :
                        $c =~ '%%G' ? '#2F2' :
                        $c =~ '%%A' ? '#FF0' : undef);
      $out .= "<SPAN STYLE='color:$current_color'>";
      $out .= '<BLINK>'  if ($blinking_p);       # restart blink

    } elsif ($c eq '%%B') {
      if (! $blinking_p) {
        $blinking_p = 1;
        $out .= "<BLINK>";
      }

    } elsif ($c eq '%%E') {
      if ($blinking_p) {
        $blinking_p = 0;
        $out .= "</BLINK>";
      }

    } elsif ($c eq '%%X') {
      $out .= ("<SPAN STYLE='background:" .
               ($current_color ? $current_color : '#2F2') .
               "'>&nbsp;</SPAN>");

    } elsif ($c eq "\n") {   # newline turns off blink and colors
      if ($blinking_p) {
        $blinking_p = 0;
        $out .= "</BLINK>";
      }
      if ($current_color) {
        $current_color = '';
        $out .= '</SPAN>';
      }
      $out .= '<BR>';

    } else { 
      $out .= $c;
    }
  }

  $out .= "</BLINK>" if ($blinking_p);
  $out .= "</SPAN>"  if ($current_color);

  $out =~ s@<BLINK></BLINK>@@gsi;  # this happens sometimes...

  return $out;
}


1;
