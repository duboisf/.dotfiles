; extends
((identifier) @_graphql_ident (#vim-match? @_graphql_ident "\\cgraphql")
    value: (expression_list
        (raw_string_literal) @graphql))
