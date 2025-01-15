# From: https://marc.info/?l=graphviz-interest&m=115396062000535
# Usage: gvpr -aX -ffwd.g input.dot

BEG_G {
   graph_t sg = subg ($, "reachable");
   $tvtype = TV_fwd;
   $tvroot = node($,ARGV[0]);
}

N {$tvroot = NULL; subnode (sg, $); }

END_G {
   induce (sg);
   write (sg);
}
