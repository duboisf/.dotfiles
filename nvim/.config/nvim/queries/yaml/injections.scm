; extends

; For GitHub's gh cli config, highlight aliases as bash scripts
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @_aliases_key (#eq? @_aliases_key "aliases")))
  value: (block_node
    (block_mapping
      (block_mapping_pair
        ; use the wildcard node (_) to match any value child nodes as there are
        ; many types, like string_scalar, single_quote_scalar, etc.
        value: (_
          (_) @bash)))))

; For GitHub composite actions
(
 (block_mapping_pair
    key: (flow_node
      (plain_scalar
        (string_scalar) @using_key (#eq? @using_key "using")))
    value: (_) @composite_value (#match? @composite_value "^['\"]composite['\"]$"))
 (block_mapping_pair
    key: (flow_node
      (plain_scalar
        (string_scalar) @steps_key (#eq? @steps_key "steps")))
    value: (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_mapping
              (block_mapping_pair
                key: (_) @run_key (#match? @run_key "run")
                value: (block_node
                  (block_scalar
                    "|") @bash))))))))
 )
