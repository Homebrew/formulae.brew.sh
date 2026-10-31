---
layout: page
title: Analytics Data
redirect_from: /analytics-linux/
---
Analytics include reported usage events, package downloads and repository history.

<ul>
  <li><a href="#reports">Reports</a></li>
  <li><a href="#events">Events</a></li>
</ul>

<h3 id="reports">Reports</h3>

| Report | Contents |
| --- | --- |
| [Repository analytics](github/) | Current and annual PR, issue, security advisory, contributor, release and catalogue counts from 2009 onwards. |
| [Homebrew release analytics](releases/) | Release history and commits, PR references and contributors per release from Git. |
| [Package download analytics](github-packages/) | GitHub download counts compared with 30-day install events. |
| [Package history analytics](formula-history/) | Formula version updates, revisions and bottle rebuilds, plus formula and cask catalogue history. |
| [Package security analytics](security/) | The advisory database and findings for current formula versions. |

<h3 id="events">Events</h3>

<table>
    <thead><tr><th scope="col">Report</th><th scope="col" colspan="3">Range</th></tr></thead>
    <tbody>
    <tr>
        <td>Formula Install Events</td>
        <td><a href="{{ site.baseurl }}/analytics/install/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/install/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/install/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Formula Install On Request Events</td>
        <td><a href="{{ site.baseurl }}/analytics/install-on-request/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/install-on-request/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/install-on-request/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Cask Install Events</td>
        <td><a href="{{ site.baseurl }}/analytics/cask-install/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/cask-install/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/cask-install/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Formula Build Error Events</td>
        <td><a href="{{ site.baseurl }}/analytics/build-error/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/build-error/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/build-error/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>OS Versions for Events</td>
        <td><a href="{{ site.baseurl }}/analytics/os-version/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/os-version/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/os-version/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Homebrew Developer Configuration for Events</td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-devcmdrun-developer/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-devcmdrun-developer/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-devcmdrun-developer/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Homebrew Environment Configuration Events</td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-env-config/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-env-config/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-env-config/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>OS/Architecture/CI for Events</td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-os-arch-ci/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-os-arch-ci/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-os-arch-ci/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Homebrew Prefixes for Events</td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-prefixes/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-prefixes/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-prefixes/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Homebrew Versions for Events</td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-versions/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-versions/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/homebrew-versions/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Homebrew Command Events</td>
        <td><a href="{{ site.baseurl }}/analytics/brew-command-run/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/brew-command-run/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/brew-command-run/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Homebrew Command and Options Events</td>
        <td><a href="{{ site.baseurl }}/analytics/brew-command-run-options/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/brew-command-run-options/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/brew-command-run-options/365d/">365 days</a></td>
    </tr>
    <tr>
        <td>Homebrew Core Test Bot Events</td>
        <td><a href="{{ site.baseurl }}/analytics/brew-test-bot-test/30d/">30 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/brew-test-bot-test/90d/">90 days</a></td>
        <td><a href="{{ site.baseurl }}/analytics/brew-test-bot-test/365d/">365 days</a></td>
    </tr>
    <tr>
        <td><code>/api/analytics/install/homebrew-core/${DAYS}.json</code> (JSON API)</td>
        <td><a href="{{ site.baseurl }}/api/analytics/install/homebrew-core/30d.json">30 days</a></td>
        <td><a href="{{ site.baseurl }}/api/analytics/install/homebrew-core/90d.json">90 days</a></td>
        <td><a href="{{ site.baseurl }}/api/analytics/install/homebrew-core/365d.json">365 days</a></td>
    </tr>
    <tr>
        <td><code>/api/analytics/install-on-request/homebrew-core/${DAYS}.json</code> (JSON API)</td>
        <td><a href="{{ site.baseurl }}/api/analytics/install-on-request/homebrew-core/30d.json">30 days</a></td>
        <td><a href="{{ site.baseurl }}/api/analytics/install-on-request/homebrew-core/90d.json">90 days</a></td>
        <td><a href="{{ site.baseurl }}/api/analytics/install-on-request/homebrew-core/365d.json">365 days</a></td>
    </tr>
    <tr>
        <td><code>/api/analytics/cask-install/homebrew-cask/${DAYS}.json</code> (JSON API)</td>
        <td><a href="{{ site.baseurl }}/api/analytics/cask-install/homebrew-cask/30d.json">30 days</a></td>
        <td><a href="{{ site.baseurl }}/api/analytics/cask-install/homebrew-cask/90d.json">90 days</a></td>
        <td><a href="{{ site.baseurl }}/api/analytics/cask-install/homebrew-cask/365d.json">365 days</a></td>
    </tr>
    <tr>
        <td><code>/api/analytics/build-error/homebrew-core/${DAYS}.json</code> (JSON API)</td>
        <td><a href="{{ site.baseurl }}/api/analytics/build-error/homebrew-core/30d.json">30 days</a></td>
        <td></td>
        <td></td>
    </tr>
    </tbody>
</table>
