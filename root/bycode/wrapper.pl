#
# our universal wrapper
# building the scaffolding for all pages
#
doctype 'xhtml';
html {
  head {
      title { stash->{title} || 'untitled' };
      load Js  => qw(prototype scriptaculous effects dragdrop default.js);
      load Css => 'site.css';
      # load Js => 'dragdrop'; # will append to load Js above...
  };
  body {
      with {id => 'header'}  div { yield 'header'; };
      with {id => 'main', class => 'clearfix'} div {
          with {id => 'leftnav'} div { yield 'leftnav'; };
          with {id => 'content'} div { yield; };
      };
      with {id => 'footer'}  div { yield 'footer'; };
  };
};
