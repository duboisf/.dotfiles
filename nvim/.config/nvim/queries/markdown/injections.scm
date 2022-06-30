; Highlight yaml headers in markdown files. These headers look like this:
;
; ---
; id: blah
; date: 2022-06-30
; ---
;
; # some markdown title
;
; ... rest of markdown content
(
    (section .
        (thematic_break))
    (section .
        (setext_heading .
            heading_content: (paragraph) @yaml))
)
