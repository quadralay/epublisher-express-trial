<!--markers:{"Keywords": "troubleshooting, errors, sync issues, conflicts, diagnostics, support", "Description": "Resolve common Quantum Sync issues including sync failures, conflicts, and connection problems"} ; #troubleshooting-->
## Troubleshooting

This section covers common issues and their solutions. If you cannot resolve a problem using these steps, contact support at $SupportEmail;.

### Common Issues

<!--style:Issue ; #issue-files-not-syncing-->
#### Files not syncing

If files in your sync folder are not uploading or downloading:

- Check that you are connected to the internet
- Verify $ProductName; is running (look for the icon in your system tray)
- Ensure you have not paused synchronization
- Check available storage in your cloud account

<!--style:Issue ; #issue-sync-conflicts-->
#### Sync conflicts

[Conflicts](#gloss-term-conflict) occur when the same file is modified on multiple devices before syncing completes. $ProductName; preserves both versions by renaming the conflicting copy with a timestamp suffix.

To resolve a conflict:

1. Open both versions of the file
2. Compare the changes manually or use a diff tool
3. Merge the changes into a single file
4. Delete the conflicting copy

<!--style:Issue ; #issue-connection-errors-->
#### Connection errors

If $ProductName; cannot connect to the server, check your network settings and firewall configuration. The application requires outbound access on ports 443 (HTTPS) and 8443 (WebSocket).

### Diagnostic Commands

Use the built-in diagnostic tool to gather information for support requests:

```
quantumsync --diagnose
```

This command outputs system information, network status, and recent sync logs. You can save the output to a file:

```
quantumsync --diagnose > diagnostic-report.txt
```

> **Note:** Diagnostic reports may contain file names from your sync folder. Review the report before sharing it with support if you have sensitive file names.

<!--condition:print_only-->
For additional troubleshooting steps, see the online knowledge base at quantumsync.example/support or contact support using the information on the back cover of this guide.
<!--/condition-->

### Getting Help

If you cannot resolve your issue using the steps above:

- Search the knowledge base at quantumsync.example/support
- Post in the community forums at community.quantumsync.example
- Contact support at $SupportEmail;

For definitions of technical terms used in this section, see the [Glossary](#glossary).
