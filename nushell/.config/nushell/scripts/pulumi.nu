use ~/.config/nushell/scripts/utils.nu notify

export def "pup" [] {
    pulumi up
    notify $"Updated stack (pulumi stack --show-name)" $"in project (open 'Pulumi.yaml' | get name)"
}
