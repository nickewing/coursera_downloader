Coursera Downloader
===================

Download static versions of Coursera course websites for offline reference.

Install
-------
Download and install with the following command:

    gem install coursera_downloader

Use
---
After installing the Ruby gem, use the `coursera_downloader` command to download
a course like so:

    coursera_downloader course-identifier email password destination-directory [policy-file]

For example, to download the first offering of the Neural Networks class, run
the following command:
    
    coursera_downloader neuralnets-2012-001 foo.bar@example.com password123 neuralnets

Default Policy File
-------------------
The policy file defines Ruby regular expressions used to determine how to handle
new URLs found on the course page.  It is in the YAML format.

The default policy file is shown below.

    ---
    whitelist:
    - ^https?://class\.coursera\.org/[^/]+/
    - ^https?://[^\.]+\.s3\.amazonaws\.com
    - ^https?://s3\.amazonaws\.com
    - ^https?://[^\.]+\.cloudfront\.net
    blacklist:
    - \.(exe|dmg)(\?.*)?$
    disable:
    # - ^https?://class\.coursera\.org/[^/]+/quiz
    # - ^https?://class\.coursera\.org/[^/]+/forum
    # - ^https?://class\.coursera\.org/[^/]+/lecture
    # - ^https?://class\.coursera\.org/[^/]+/wiki
    - ^https?://class\.coursera\.org/[^/]+/forum/thread?.*view=.*
    - ^https?://class\.coursera\.org/[^/]+/forum/tag?.*view=.*
    - ^https?://class\.coursera\.org/[^/]+/forum/list?.*view=.*
    - ^https?://class\.coursera\.org/[^/]+/forum/toggle
    - ^https?://class\.coursera\.org/[^/]+/forum/tag_modify
    - ^https?://class\.coursera\.org/[^/]+/quiz/start
    - ^https?://class\.coursera\.org/[^/]+/generic/apply_late_days
    - ^https?://class\.coursera\.org/[^/]+/auth/logout
    - ^https?://class\.coursera\.org/[^/]+/class/preferences

License
-------
Coursera Downloader is available under an MIT-style license.

See LICENSE.

This software should only be used in accordance to Coursera's Terms of Service.
Please see: https://www.coursera.org/about/terms

Copyright (C) 2012 by Nick Ewing
