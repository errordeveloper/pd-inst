# this is a rough attempt to bind keys to little snippets of patches.
# Currently, there are only three keys bound: o r s

package require pd_connect ;# for pdsend

namespace eval ::patch_by_key:: {
}

proc ::patch_by_key::mapping {key} {
    # map keys to patch snippets
    switch -- $key {
        o {return "#X obj 1 2 osc~;"}
        r {return "#X obj 1 2 r test;"}
        s {return "#X obj 1 2 s test;"}
        default {return ""}
    }
}

proc ::patch_by_key::key {window key x y} {
    set mytoplevel [winfo toplevel $window]
    # only do this for PatchWindows, not dialogs, pdwindow, etc.
    if {[winfo class $mytoplevel] ne "PatchWindow"} {return}
    # only do this if the canvas is in editmode
    if {$::editmode($mytoplevel) != 1} {return}
    # don't do anything if editing obj, msg, comment
    if {$::editingtext($mytoplevel)} {return}
    # get the text that matches the key, or quit
    set snippet [mapping $key]
    if {$snippet eq ""} {return}

    set tkcanvas [tkcanvas_name $mytoplevel]
    # regexp magic to replace #X with the current canvas name, and the
    # (x,y) with the current mouse location
    set x [$tkcanvas canvasx $x]
    set y [$tkcanvas canvasy $y]
    pdsend [regsub -- {#X (\S+) [0-9]+ [0-9]+} $snippet "$mytoplevel \\1 $x $y"]

}

bind all <Key> "+::patch_by_key::key %W %K %x %y"
