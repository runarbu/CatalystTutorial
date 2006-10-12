<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
 <head><?cs
  if:project.name ?>
  <title><?cs if:title ?><?cs var:title ?> - <?cs /if ?><?cs
    var:project.name?> - Trac</title><?cs
  else ?>
  <title>Trac: <?cs var:title ?></title><?cs
  /if ?><?cs
  if:html.norobots ?>
  <meta name="ROBOTS" content="NOINDEX, NOFOLLOW" /><?cs
  /if ?><?cs
  each:rel = links ?><?cs each:link = rel ?>
  <link rel="<?cs var:name(rel) ?>" href="<?cs var:link.href ?>"<?cs
   if:link.title ?> title="<?cs var:link.title ?>"<?cs /if ?><?cs
   if:link.type ?> type="<?cs var:link.type ?>"<?cs /if ?> /><?cs
  /each ?><?cs /each ?>
  <style type="text/css">
   @import url(<?cs var:htdocs_location ?>css/trac.css);
   <?cs if:html.stylesheet ?>@import url(<?cs var:htdocs_location ?><?cs
     var:html.stylesheet ?>);<?cs /if ?>
   <?cs include "site_css.cs" ?>
  </style>
  <link rel="stylesheet" type="text/css" href="<?cs var:htdocs_location ?>css/global/generic.css" media="screen" />
  <link rel="stylesheet" type="text/css" href="<?cs var:htdocs_location ?>css/global/layout.css" media="screen" />
  <!--[if lt IE 7]>
	<link rel="stylesheet" type="text/css" href="<?cs var:htdocs_location ?>css/global/ie.css" media="screen" />
  <![endif]-->
  <script src="<?cs var:htdocs_location ?>trac.js" type="text/javascript"></script>
 </head>

  <?cs if:$trac.active_module == "timeline" ?>
    <?cs set:$catalyst_body_class="developer" ?>
  <?cs elif:$trac.active_module == "browser" ?>
    <?cs set:$catalyst_body_class="developer" ?>
  <?cs elif:$trac.active_module == "log" ?>
    <?cs set:$catalyst_body_class="developer" ?>
  <?cs elif:$trac.active_module == "filer" ?>
    <?cs set:$catalyst_body_class="developer" ?>
  <?cs elif:$trac.active_module == "chageset" ?>
    <?cs set:$catalyst_body_class="developer" ?>
  <?cs elif:$trac.active_module == "wiki" && $wiki.page_name == "Support" ?>
    <?cs set:$catalyst_body_class="support" ?>
  <?cs elif:$trac.active_module == "wiki" && $wiki.page_name == "Documentation" ?>
    <?cs set:$catalyst_body_class="documentation" ?>
  <?cs elif:$trac.active_module == "wiki" && $wiki.page_name == "Download" ?>
    <?cs set:$catalyst_body_class="download" ?>
  <?cs else ?>
    <?cs set:$catalyst_body_class="community" ?>
  <?cs /if ?>

  <!-- <?cs var:trac.active_module ?> -->
 
<body class="<?cs var:catalyst_body_class ?>">
<div id="wrapper">
<?cs include "site_header.cs" ?>
<div id="header">

<h1>
  <a id="logo" href="<?cs var:header_logo.link ?>"><img src="<?cs var:header_logo.src ?>"
      width="<?cs var:header_logo.width ?>" height="<?cs var:header_logo.height ?>"
      alt="<?cs var:header_logo.alt ?>" /></a>
</h1>

<form id="search" action="<?cs var:trac.href.search ?>" method="get">
 <?cs if:trac.acl.SEARCH_VIEW ?><div>
  <label for="proj-search">Search:</label>
  <input type="text" id="proj-search" name="q" size="10" value="" />
  <input type="submit" value="Search" />
  <input type="hidden" name="wiki" value="on" />
  <input type="hidden" name="changeset" value="on" />
  <input type="hidden" name="ticket" value="on" />
 </div><?cs /if ?>
</form>

<div id="metanav" class="nav">
 <h2>Navigation</h2>
 <ul>
  <li class="first"><?cs if:trac.authname == "anonymous" || !trac.authname ?>
    <a href="<?cs var:trac.href.login ?>">Login</a>
  <?cs else ?>
    logged in as <?cs var:trac.authname ?> </li>
    <li><a href="<?cs var:trac.href.logout ?>">Logout</a>
  <?cs /if ?></li>
  <li><a href="<?cs var:trac.href.settings ?>">Settings</a></li>
  <li><a accesskey="6" href="<?cs var:trac.href.wiki ?>/TracGuide">Help/Guide</a></li>
  <li style="display: none"><a accesskey="5" href="http://projects.edgewall.com/trac/wiki/TracFaq">FAQ</a></li>
  <li style="display: none"><a accesskey="0" href="<?cs var:trac.href.wiki ?>/TracAccessibility">Accessibility</a></li>
  <li class="last"><a accesskey="9" href="<?cs var:trac.href.about ?>">About Trac</a></li>
 </ul>
</div>

<div>
	<ul id="menu_global">
		<li id="home"><span><a href="http://catalyst.perl.org/">Home</a></span></li> 
		<li id="community"><span><a href="http://dev.catalyst.perl.org/">Community</a></span></li>
		<li id="documentation"><span><a href="http://search.cpan.org/dist/Catalyst/lib/Catalyst/Manual.pod">Documentation</a></span></li>
		<li id="developer"><span><a href="http://dev.catalyst.perl.org/timeline">Developer</a></span></li>
		<li id="download"><span><a href="http://search.cpan.org/dist/Catalyst/">Download</a></span></li>
                <li id="blog"><span><a href="http://catalyst.perl.org/random/">Blog</a></span></li>
		<li id="support"><span><a href="http://dev.catalyst.perl.org/wiki/Support">Support</a></span></li>
        <li id="calendar"><span style="font-weight: bold;"><a href="http://catalyst.perl.org/calendar/">Advent Calendar</a></span></li>
	</ul>
</div>

</div>

<?cs def:navlink(text, href, id, aclname, accesskey) ?><?cs
 if $aclname ?><li><a href="<?cs var:href ?>"<?cs 
  if $id == $trac.active_module ?> class="active"<?cs
  /if ?><?cs
  if:$accesskey!="" ?> accesskey="<?cs var:$accesskey ?>"<?cs 
  /if ?>><?cs var:text ?></a></li><?cs 
 /if ?><?cs
/def ?>

<?cs if $trac.active_module == "wiki" ?><?cs
  set:$wiki_view="wiki" ?><?cs
 else  ?><?cs
  set:$wiki_view="attachment" ?><?cs
 /if  ?><?cs
 if $trac.active_module == "ticket" ?><?cs
  set:$ticket_view="ticket" ?><?cs
 elif $trac.active_module == "query" ?><?cs
  set:$ticket_view="query" ?><?cs
 else ?><?cs
  set:$ticket_view="report" ?><?cs
 /if  ?><?cs
 if $trac.active_module == "log" ?><?cs
  set:$browser_view="log" ?><?cs
 elif $trac.active_module == "file" ?><?cs
  set:$browser_view="file" ?><?cs
 else  ?><?cs
  set:$browser_view="browser" ?><?cs
 /if  ?><?cs
 if $trac.active_module == "milestone" ?><?cs
  set:$roadmap_view="milestone" ?><?cs
 else ?><?cs
  set:$roadmap_view="roadmap" ?><?cs 
 /if ?>

<div id="mainnav" class="nav">
 <ul><?cs
  call:navlink("Wiki", trac.href.wiki, wiki_view,
               trac.acl.WIKI_VIEW, "1") ?><?cs
  call:navlink("Timeline", trac.href.timeline, "timeline",
               trac.acl.TIMELINE_VIEW, "2") ?><?cs
  call:navlink("Roadmap", trac.href.roadmap, roadmap_view,
               trac.acl.ROADMAP_VIEW, "3") ?><?cs
  call:navlink("Browse Source", trac.href.browser, browser_view,
               trac.acl.BROWSER_VIEW, "") ?><?cs
  call:navlink("View Tickets", trac.href.report, ticket_view,
               trac.acl.REPORT_VIEW, "") ?><?cs
  call:navlink("New Ticket", trac.href.newticket, "newticket",
               trac.acl.TICKET_CREATE, "7") ?><?cs
  call:navlink("Search", trac.href.search, "search",
               trac.acl.SEARCH_VIEW, "4") ?></ul>
</div>

<div id="main">
