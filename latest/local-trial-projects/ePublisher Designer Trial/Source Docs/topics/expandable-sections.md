<!-- markers:{"Keywords": "troubleshooting, errors, sync issues, conflicts, diagnostics, support, performance", "Description": "Resolve common Quantum Sync issues including sync failures, conflicts, connection problems, and performance."}; #troubleshooting -->
## Troubleshooting

This section covers common issues and their solutions. If you cannot resolve a problem using the steps below, contact support at $SupportEmail;.

### Common Issues

<!-- style:Issue ; marker:IndexMarker="troubleshooting:files not syncing" ; #issue-files-not-syncing -->
#### Files not syncing

If files in your sync folder are not uploading or downloading:

- Check that you are connected to the internet
- Verify $ProductName; is running (look for the icon in your system tray)
- Ensure you have not paused synchronization
- Check available storage in your cloud account at quantumsync.example/account

If none of these steps resolve the issue, try restarting the sync service:

```bash
quantumsync service restart
```

<!-- style:Issue ; marker:IndexMarker="troubleshooting:sync conflicts,conflicts:resolving" ; #issue-sync-conflicts -->
#### Sync conflicts

[Conflicts](glossary.md#gloss-term-conflict) occur when the same file is modified on multiple devices before syncing completes. $ProductName; preserves both versions by renaming the conflicting copy with a timestamp suffix (for example, `report (conflicted 2026-03-01).docx`).

To resolve a conflict:

1. Open both versions of the file
2. Compare the changes manually or use a diff tool
3. Merge the desired changes into a single file
4. Delete the conflicting copy
5. Wait for the merged file to sync to all devices

<!-- style:Issue ; marker:IndexMarker="troubleshooting:connection errors,network:ports" ; #issue-connection-errors -->
#### Connection errors

If $ProductName; cannot connect to the server, check your network settings and firewall configuration. The application requires outbound access on the following ports:

| Port | Protocol | Purpose |
|-----:|----------|---------|
| 443  | HTTPS    | API communication and file transfer |
| 8443 | WebSocket| Real-time change notifications |

If your organization uses a proxy server, configure it in [Network Settings](conditions-and-variables.md#network-settings).

<!-- style:Issue ; marker:IndexMarker="troubleshooting:slow sync,performance:optimization" ; #issue-slow-performance -->
#### Slow sync performance

If file synchronization is slower than expected:

1. **Check bandwidth limits** — Open [Sync Settings](conditions-and-variables.md#sync-settings) and verify that upload and download limits are not set too low
2. **Reduce concurrent transfers** — If you are syncing thousands of small files, $ProductName; may perform better with fewer concurrent connections
3. **Switch to a wired connection** — Ethernet connections provide more consistent throughput than Wi-Fi
4. **Exclude unnecessary files** — Add large temporary files and build artifacts to your ignore patterns:

   ```
   *.tmp
   *.log
   node_modules/
   .git/
   build/
   ```

<!-- style:Issue ; #issue-high-cpu-usage -->
#### High CPU usage

If $ProductName; uses excessive CPU resources:

- Check whether a large initial sync is in progress (first sync after installation is resource-intensive)
- Ensure your sync folder does not contain an unusually large number of small files (more than 100,000)
- Update to the latest version of $ProductName; — performance improvements are included in each release

<!-- marker:IndexMarker="diagnostics:commands,troubleshooting:diagnostic tools" ; #diagnostics -->
### Diagnostic Tools

Use the built-in diagnostic tool to gather information for support requests:

```bash
quantumsync --diagnose
```

This command outputs system information, network status, and recent sync logs. Save the output to a file for support:

```bash
quantumsync --diagnose > diagnostic-report.txt
```

Additional diagnostic commands:

```bash
# Check sync queue status
quantumsync queue --status

# View recent sync activity
quantumsync log --tail 50

# Test server connectivity
quantumsync ping --verbose
```

> **Note:** Diagnostic reports may contain file names from your sync folder. Review the report before sharing it with support if your folder contains sensitive file names.

<!-- condition:print_only -->
For additional troubleshooting steps, see the online knowledge base at quantumsync.example/support or contact support using the information on the back cover of this guide.
<!-- /condition -->

<!-- #getting-help -->
### Getting Help

If you cannot resolve your issue using the steps above:

- Search the knowledge base at quantumsync.example/support
- Post in the community forums at community.quantumsync.example
- Contact support directly at $SupportEmail;

<!-- condition:online_only -->
When contacting support, include the output of `quantumsync --diagnose` to help the support team identify your issue quickly.
<!-- /condition -->

For definitions of technical terms used in this section, see the [Glossary](glossary.md#glossary).
