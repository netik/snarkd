# snarkfilter - dirty words filter

sub snarkFilter {
    $chkmsg = shift;
    $origmsg = $chkmsg;
#    $chkmsg =~ s/%%.//g;

    # get rid of dirty words
    $chkmsg =~ s/asshat/%%Rsnarkhat%%G/gi;
    $chkmsg =~ s/butthole/%%Rsnark%%G/gi;
    $chkmsg =~ s/fuck/%%Rsnark%%G/gi;
    $chkmsg =~ s/cunt/%%Rsnark%%G/gi;
    $chkmsg =~ s/shit/%%Rsnark%%G/gi;
    $chkmsg =~ s/sh1t/%%Rsnark%%G/gi;
    $chkmsg =~ s/nigger/%%Rsnarker%%G/gi;
    $chkmsg =~ s/n1gger/%%Rsnarker%%G/gi;
    $chkmsg =~ s/n1gg3r/%%Rsnarker%%G/gi;
    $chkmsg =~ s/spick/%%Rsnarker%%G/gi;
    $chkmsg =~ s/sp1ck/%%Rsnarker%%G/gi;
    $chkmsg =~ s/bitch/%%Rsnark%%G/gi;
    $chkmsg =~ s/bastard/%%Rsnark%%G/gi;
    $chkmsg =~ s/whore/%%Rsnark%%G/gi;
    $chkmsg =~ s/slut/%%Rsnark%%G/gi;
    $chkmsg =~ s/fag/%%Rsnark%%G/gi;
    $chkmsg =~ s/faggot/%%Rsnark%%G/gi;
    $chkmsg =~ s/gay/%%Rsnark%%G/gi;
    $chkmsg =~ s/fairy/%%Rsnark%%G/gi;
    $chkmsg =~ s/lesbian/%%Rsnark%%G/gi;
    $chkmsg =~ s/lesb1an/%%Rsnark%%G/gi;
    $chkmsg =~ s/twat/%%Rsnark%%G/gi;
    $chkmsg =~ s/kike/%%Rsnark%%G/gi;
    $chkmsg =~ s/punta/%%Rsnark%%G/gi;
    $chkmsg =~ s/jewbag/%%Rsnark%%G/gi;
    $chkmsg =~ s/jew bag/%%Rsnark%%G/gi;
    $chkmsg =~ s/j00bag/%%Rsnark%%G/gi;
    $chkmsg =~ s/j00/%%Rsnark%%G/gi;
    $chkmsg =~ s/fartknocker/%%Rsnarksnarker%%G/gi;
    $chkmsg =~ s/cock/%%Rsnark%%G/gi;
    $chkmsg =~ s/c0ck/%%Rsnark%%G/gi;
    $chkmsg =~ s/c\*ck/%%Rsnark%%G/gi;
    $chkmsg =~ s/fcuk/%%Rsanrk%%G/gi;
    $chkmsg =~ s/schtample/%%Rkrautsnark%%G/gi;
    $chkmsg =~ s/ass/%%Rsnark%%G/gi;
    $chkmsg =~ s/arse/%%Rsnark%%G/gi;
    $chkmsg =~ s/wigger/%%Rsnark%%G/gi;
    $chkmsg =~ s/w1gger/%%Rsnark%%G/gi;
    $chkmsg =~ s/pollack/%%Rsnark%%G/gi;
    $chkmsg =~ s/p0llack/%%Rsnark%%G/gi;
    $chkmsg =~ s/beaner/%%Rsnark%%G/gi;
    $chkmsg =~ s/bean3r/%%Rsnark%%G/gi;
    $chkmsg =~ s/b3an3r/%%Rsnark%%G/gi;
    $chkmsg =~ s/kraut/%%Rsnark%%G/gi;
    $chkmsg =~ s/cockbiter/%%Rsnarkbiter%%G/gi;
    $chkmsg =~ s/cock(-*)biting/%%Rsnark$1biting%%G/gi;
    $chkmsg =~ s/motherfucker/%%Rmothersnarker%%G/gi;
    $chkmsg =~ s/m(u|o)thafucka/%%Rsnarkasnarka%%G/gi;

    $chkmsg =~ s/pussy/%%Rsnarkasnarka%%G/gi;
    $chkmsg =~ s/vag[i1]na/%%Rsnark%%G/gi;
    $chkmsg =~ s/pr[i1]ck/%%Rsnark%%G/gi;

    $chkmsg =~ s/tossa/%%Rsnark%%G/gi;
    $chkmsg =~ s/tosser/%%Rsnark%%G/gi;
    $chkmsg =~ s/knobhead/%%Rsnark%%G/gi;
    $chkmsg =~ s/wanker/%%Rsnark%%G/gi;
    $chkmsg =~ s/wog/%%Rsnark%%G/gi;
    $chkmsg =~ s/c[0o][0o]n/%%Rsnark%%G/gi;
    $chkmsg =~ s/camelj[o0]ckey/%%Rsnark%%G/gi;
    $chkmsg =~ s/sandn[1i]gger/%%Rsnark%%G/gi;
    $chkmsg =~ s/p[0o][0o]n/%%Rsnark%%G/gi;
    $chkmsg =~ s/porchmonkey/%%Rsnark%%G/gi;
    $chkmsg =~ s/porchsw[i1]nger/%%Rsnark%%G/gi;

    return $chkmsg;

# This doesn't work. 
#    if ($chkmsg ne $origmsg) { 
#	# you lost formatting. 
#	return $chkmsg;
#    } else {
#	# you ok
#	return $origmsg;
#    }

}

1;
