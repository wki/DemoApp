///////////////////////////////////////////////////////////////////
//
// some widgets that expand HTML things
//
/*
   anatomy of a popup

   <fieldset class="widget">       // entire widget (inline element)
     - extra class "expanded" is set when popup is visible
     - extra class "disabled" to disable
     - special classes:
       -type-x  to create different widget types - TBD
       -name-x  is set to autocreate a hidden field
       -value-x is set to autofill the hidden field
       -width-x or CSS-styling if wanted
       -height-x or CSS-styling if wanted
       -center  is set to center selected value
       -multiple to allow multiple values to get set (separated by space)

     <ul class="popup">...</ul>     // ... popup contents
     <div class="popup">...</div>   // alternative way

     <div class="container">       // widget contents (block element)
       - internally used for sizing the entire widget
       - autocreated if not initially there

       <img class="trigger"/>      // the trigger element, typically right
       <div class="text">...</div> // the visible text
     </div>

   </fieldset>


   examples:
   <fieldset class="widget -name-thename -value-123 -type-select">
     <ul class="popup"><!-- the selectable options -->
       <li value="1">123</li>
       <li value="2">456</li>
     </ul>
   </fieldset>

   <fieldset class="widget -type-search -url-how_to_encode_it?">
   </fieldset>

   Constructor Usage:
   new Popup.Xxx(element, options)

   options:
     --everything from Popup (lowercased) to override defaults
     values: [] array of scalars or {display: ..., value: ...} pairs

 */

//
// create a namespace
//
var Popup = {
    //
    // some CSS-constants
    //
    WIDGET:    'widget',       // the whole widget
    CONTAINER: 'container',    // the div box for sizing
    DISABLED:  'disabled',     // a completely disabled widget
    EXPANDED:  'expanded',     // make popup visible
    SELECTED:  'selected',     // a selected <LI> inside the popup
    POPUP:     'popup',        // the popup box
    TRIGGER:   'trigger',      // the trigger image
    T_IMAGE:   '../images/resultset_next.png',
    TEXT:      'text',         // the clipping text box

    //
    // DATE CONSTANTS
    //
    DATE_REGEXP: '(\\d+)-(\\d+)-(\\d+)',
    DATE_ORDER:  $w('yyyy mm dd'),
    DATE_FORMAT: '#{yyyy}-#{mm}-#{dd}',
    DATE_DAYS:   $w('Mo Di Mi Do Fr Sa So'),
    DATE_MONTHS: $w('Januar Februar Marz April Mai Juni Juli August September Oktober November Dezember'),

    //
    // some Browser variables -- may be corrected during first initialization
    // theoretically not of intereset, could get eliminated
    // because we only set an iframe for IE6
    //
    IE6: false,
    IE7: false
};

//
// a generic base-class for building popup widgets
//
// Options:
//   * expanded: class of expanded widget (defaults to 'expanded')
//   * selected: class of selected Popup LI element (defaults to 'selected')
//   * disabled: class of disabled widget class (defaults to 'disabled')
//   * values: array of values for simple popups
//
// only date-widget:
//   * date_format: date-format for date-picler (defaults to 'yyyy-mm-dd')
//   * date_regexp: regexp for matching above date format
//   * date_order: list of fields in right order for the regexp above
//   * TODO: date_days - day names -> done
//   * TODO: date_months - month names
//
// only Ajax-Widget:
//   * TODO: url: ... the url to call for getting list (result is HTML)
//   + Popup.AjaxSearch ... done
//   - Popup.Date ... todo
//   - Popup.Base ... todo
//
Popup.Base = Class.create({
    // will be generated automatically --
    // holds a reference of the currently open popup or NULL
    //
    //
    // _open_popup: null,

    // will be generated automatically --
    // the iframe for IE6 for overlapping <select> boxes
    //
    // _iframe: null,

    // must be overloaded by others --
    // holds a template to use in case the popup-div is empty
    //
    _template: '&nbsp;'
        + '<div class="text">#{display}</div>'
        + '<img class="trigger" src="#{image_url}" />'
        + '<div class="popup">#{content}</div>',

    //
    // constructor
    //
    initialize: function(element, options) {
        // our widget element
        this._element = $(element);
        if (! this._element) return;

        // set options
        // if (this._element.hasClassName('_month')) { //
        if (this._element.className.match(/\b_month/)) {
            this._options = options || {values: $A(Popup.DATE_MONTHS)};
        } else {
            this._options = options || {};
        }
        
        this._is_multi_select = this._element.className.match(/-multiple/) ? true : false;

        // our popup (adding .popup if needed)
        this._popup = this._element.down('.-popup');
        if (!this._popup) {
            // try to find something adequate
            this._popup = this._element.firstDescendant();
            if (this._popup) {
                this._popup.addClassName(this._options.expanded || Popup.EXPANDED);
            }
        }

        // the (optional) text-containing element
        this._text = this._element.down('.-display');

        // our field (adding one of needed)
        this._hidden_field = this._element.down('input[type="hidden"]');
        if (!this._hidden_field && this._element.readAttribute('name')) {
            //if (console) { console.log('add hidden field'); }
            var field = new Element('input',
                                    {type: 'hidden',
                                     name: this._element.readAttribute('name'),
                                     value: this._element.readAttribute('value') || ''
                                    });
            this._element.insert(field);
            this._hidden_field = field;
        }

        // try to populate the widget's popup
        this.populateList();

        // trace clicks inside the widget
        this._element.observe('click', this.onClick.bindAsEventListener(this));

        // for the first widget instantiated: 
        //  - observe document-clicks,
        //  - check for IE6, 
        //  - create iframe
        if (Popup.Base._open_popup === undefined) {
            //
            // observe document click
            //
            document.observe('click', this.onDocumentClick.bindAsEventListener(Popup.Base));
            Popup.Base._open_popup = null;
            
            //
            // check for IE Version
            //
            if (Prototype.Browser.IE) {
                var ie_version = parseFloat(navigator.appVersion.split(';')[1].strip().split(' ')[1]);
                Popup.IE6 = (ie_version == 6);
                Popup.IE7 = (ie_version == 7);
            }
            
            //
            // only for IE6: create iframe
            //
            if (Popup.IE6) {
                var iframe = new Element('iframe',
                    {style: 'position:absolute; filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0); display:none;',
                    src: 'javascript:false;',
                    frameborder: 0
                    });
                $(document.body).insert({top: iframe}); // WK: added iFrame on TOP of document. seems better.
                Popup.Base._iframe = iframe;
            }
        }
    },

    //
    // low-level helper: construct the inside of a given UL
    //
    _populate_list: function(ul, values) {
        if (!ul || !values) return;
        // console.log('in _populate_list...');
        var html = '';
        $A(values).each(function(v) {
            html += '<li';
            if (Object.isString(v) || Object.isNumber(v)) {
                // display == value
                html += ' value="' + (v || '') + '">' + v;
            } else {
                // display and value are distinct
                html += ' value="' + (v.value || '') + '">' + v.display;
            }
            html += '</li>';
        });

        if (html == '') {
            html += '<li value="">no items found!</li>';
        }
        ul.update(html);
    },

    //
    //  a click inside the widget occured
    //
    onClick: function(e) {
        if (console) { console.log('click');}
        if (!this.isEnabled()) {
            //if (console) { console.log('test');}
            return;
        }
        if (Popup.Base._open_popup === this) {
            // forward click into popup
            this.onPopupClick(e);
        } else {
            // click inside widget - just open
            //alert('open');
            this.doShow();
        }

        // nobody else should ever see this event
        e.stop();
    },

    //
    //  CLASS FUNCTION -- a click into the document occured
    //
    onDocumentClick: function(e) {
        if (Popup.Base._open_popup) {
            Popup.Base._open_popup.doHide();
        }
    },

    //
    //  show a popup - hiding another opened popup first
    //
    doShow: function() {
        if (Popup.Base._open_popup === this) return;

        if (Popup.Base._open_popup) {
            Popup.Base._open_popup.doHide();
        }

        Popup.Base._open_popup = this;
        this._element.addClassName(this._options.expanded || Popup.EXPANDED);

        //
        // check if popup must get modified
        //
        if (this._popup &&
            this._popup.tagName.toUpperCase() == 'UL' &&
            this._hidden_field) {
            // see if checking needed
            this._popup.descendants().each(function(e) {
                e.removeClassName(this._options.selected || Popup.SELECTED);
            }, this);

            // see if we need to set the widget's content
            if ($F(this._hidden_field)) {
                // correctly handle a multiselect...
                var nr_selected = 0;
                var selected_li = null;
                
                var values = this._is_multi_select ? $w($F(this._hidden_field)) : [ $F(this._hidden_field) ];
                values.each(function(value) {
                    // console.log('check: ' + value);
                    var li = this._popup.down('li[value="' + value + '"]');
                    if (li) {
                        // console.log('field found: ' + li + ', value=' + li.readAttribute('value'), ', class=' + (this._options.selected || Popup.SELECTED));
                        li.addClassName(this._options.selected || Popup.SELECTED);
                        selected_li = li;
                        nr_selected++;
                        if (this._text) {
                            this._text.innerHTML = li.innerHTML;
                        }
                    }
                }, this);
                
                if (nr_selected == 1 && this._element.hasClassName('-center')) {
                    // centering wanted
                    //if (console) { console.log('must center, li='+li); }
                    var top = selected_li.positionedOffset()[1];
                    this._popup.setStyle({top: -top+'px'});
                } else {
                    this._popup.setStyle({top: '0px'});
                }
            }
        }

        //
        // care for iframe if needed
        //
        if (Popup.Base._iframe) {
            var element = this._popup,
                offset = element.cumulativeOffset(),  
                dimensions = element.getDimensions(),
                style = {
                    left: offset[0] + 'px',
                    top: offset[1] + 'px',
                    width: dimensions.width + 'px',
                    height: dimensions.height + 'px',
                    zIndex: 0 // NOT THIS: does not forward clicks under certain circumstances...  element.getStyle('zIndex') - 1
                };
            // console.log('>>'+this._popup.id+'>>'+this._popup.style.zIndex+'>>'+style.zIndex);
            Popup.Base._iframe.setStyle(style).show();
            //this._iframe.show();
        }

        this.onOpen();
    },

    //
    //  hide a popup
    //
    doHide: function() {
        if (Popup.Base._open_popup !== this) return;

        this.onClose();
        Popup.Base._open_popup = null;

        // care for iframe if needed
        if (Popup.Base._iframe) {
            Popup.Base._iframe.hide();
        }

        this._element.removeClassName(this._options.expanded || Popup.EXPANDED);
    },

    //
    // get enabled status
    //
    isEnabled: function() {
        return !(this._element.hasClassName(this._options.disabled || Popup.DISABLED) || this._element.readAttribute('disabled'));
    },

    //
    // enable a popup
    //
    enable: function() {
        if (this._isEnabled()) return;
        this._element.removeClassName(this._options.disabled || Popup.DISABLED);
        this._element.writeAttribute('disabled'); // does this remove?
    },

    //
    // disable a popup
    //
    disable: function() {
        if (!this._isEnabled()) return;
        this._element.addClassName(this._options.disabled || Popup.DISABLED);
    },

    //
    // set displayed text and the value into a hidden field
    //
    setValue: function(display, value) {
        // console.log('display: ' + display + ', value: ' + value);
        if (this._text) {
            this._text.innerHTML = display;
        }
        if (this._hidden_field) {
            this._hidden_field.setValue(value != null ? value : display);
        }
    },

    //////////////////////////////////////// OVERLOADABLE FUNCTIONS
    //
    // populate the list with values
    //
    populateList: function() {
        if (this._popup &&
            this._popup.tagName.toUpperCase() == 'UL' &&
            this._options.values) {
            // just populate!
            this._populate_list(this._popup, this._options.values);
        }
    },

    //
    // open Popup callback
    //
    onOpen: function() {
    },

    //
    // close Popup callback
    //
    onClose: function() {
    },

    //
    // a click into the popup
    //
    onPopupClick: function(e) {
        //console.log('popup clicked -- method not overloaded!!!');
        if (e.target.tagName.toUpperCase() == 'LI') {
            // clicked on a list entry
            if (this._is_multi_select) {
                console.log('build MULTI select value, popup = ' + this._popup.descendants().length);
                Element.toggleClassName(e.target, this._options.selected || Popup.SELECTED);
                this.setValue(this._popup
                                  .descendants()
                                  .findAll(function(x) {return x.hasClassName(this._options.selected || Popup.SELECTED)}, this)
                                  .map(function(x) {return x.readAttribute('value')})
                                  .join(' '));
            } else {
                console.log('build SINGLE select value');
                this.setValue(e.target.innerHTML, e.target.readAttribute('value'));
            }
            
            this._element.fire('widget:change');
        }
        this.doHide();
    }
});

//
// a search popup
//
Popup.Search = Class.create(Popup.Base, {
    initialize: function($super, element, options) {
        $super(element, options);

        // maybe some more initialization
        this._searchfield = this._element.down('input.-find');
        if (this._searchfield) {
            new Form.Element.Observer(this._searchfield, 0.5, this.onSearch.bind(this));
            //this._searchfield.observe('KEY_RETURN', this.onReturn.bindAsEventListener(this));
        }

        // find the result list
        this._result = this._element.down('.-result');
    },

    onOpen: function() {
        this.populateList();
        if (this._searchfield) {
            this._searchfield.focus();
        }
    },

    populateList: function() {
        // if (console) {console.log('try to populate');}
        if (!this._searchfield || !this._result || !this._options.values) return;

        // if (console) {console.log('populating');}
        var search_for = $F(this._searchfield).toUpperCase().strip();
        var values = $A(this._options.values).findAll(function(e) {
            return (!search_for || e.toUpperCase().indexOf(search_for) >= 0);
        });

        this._populate_list(this._result, values);
    },

    //onReturn: function(e) {
    //        e.stop();
    //},
    
    onPopupClick: function(e) {
        if ((e.target.tagName.toUpperCase() == 'DIV') || (e.target.tagName.toUpperCase() == 'INPUT')) {
            //alert('clicked');
            //this.setValue(e.target.innerHTML, Element.readAttribute(e.target,'value'));
            this.doHide();
        } else if (e.target.tagName.toUpperCase() == 'IMG') {
            if (e.target.className == '-close') {
                // clicked close button
                this.doHide();
            } else if (e.target.className == '-link') {
                alert('link-img clicked');
                // clicked on a img to link
                //console.log('entry+'+e.target.innerHTML+'>>'+Element.readAttribute(e.target,'value'));
                //this.setValue(e.target.innerHTML, Element.readAttribute(e.target,'value'));
                //this.doHide();
            } else {
                alert('img clicked');
            }
        } else if (e.target.tagName.toUpperCase() == 'LI') {
            alert('li clicked');
            // clicked on a list entry
            //console.log('entry+'+e.target.innerHTML+'>>'+Element.readAttribute(e.target,'value'));
            this.setValue(e.target.innerHTML, Element.readAttribute(e.target,'value'));
            this.doHide();
        } else if (e.target.tagName.toUpperCase() == 'DIV') {
            alert('div clicked');
        } else if (e.target.tagName.toUpperCase() == 'INPUT') {
            alert('picture clicked');
        }
        e.stop();
    },

    //
    // set displayed text and the value into a hidden field
    //
    setValue: function(display, value) {
        // console.log('display: ' + display + ', value: ' + value);
        if (this._text) {
            this._text.innerHTML = display;
        }
        if (this._hidden_field) {
            this._hidden_field.setValue(value != null ? value : display);
        }
    },

    onSearch: function() {
        // if (console) {console.log('new search for: ' + $F(this._searchfield));}
        this.populateList();
    }
});

//
// a search popup using an Ajax callback
//
Popup.AjaxSearch = Class.create(Popup.Search, {
    initialize: function($super, element, options) {
        $super(element, options);
        if (console) {console.log('new ajax');}
        //alert('new one');
        // find the activity layers
        this._show_result = this._element.down('.-show_result');
        this._show_wheel  = this._element.down('.-show_wheel');
        this._show_result.show();
        this._show_wheel.hide();
        this._show_search = 0;
        //alert('hier!');
    },

    
    populateList: function() {
        // make an Ajax call to find out the values of interest
        if (!this._searchfield || !this._result) return;
        //if (console) {console.log('ajax ok');}
        var search_for = $F(this._searchfield).toLowerCase().strip();
        var fart = this._hidden_field.getValue('art');
        var fid = this._hidden_field.getValue('id');
        var url = 'http://adisource.nureg.de/ajax/modules/fileBase_image_search.html'; 
        //if (console) {console.log('url: ' + url);}
        var result = this._result;
        if (search_for.length > 2) { //only search on DB from more than one letter in this field
            // load the list of values of an url into the select box
            var result_l = this._show_result;
            var wheel_l  = this._show_wheel;
            result_l.hide();
            wheel_l.show();
            var that = this;
            var args = {
                'method': 'post',
                'parameters': { q: search_for, id: fid, art: 'article' },
                'onComplete': function() {
                    wheel_l.hide();
                    result_l.show();
                    if (! result.down('li')) {
                        that._populate_list(result, []);
                        //if (console) { console.log('no results!');}
                    }
                }
            };
            new Ajax.Updater(result, url, args);
        } else if (search_for.length == 0) {
            //if (console) { console.log('start!');}
            this._populate_list(result, [{value: '', display: 'please take in at least three letters!'}]);
        } else {
            //if (console) { console.log('no search!');}
            this._populate_list(result, [{value: '', display: 'please take in at least three letters!'}]);
        }
    }
    
});

//////////////////////////////////
/*
  onSuccess: function(request) {
  if (console) {console.log('response: ' + request.responseText);}
  var array = $w(request.responseText);
  if (console) {console.log('response2: ' + array.join(','));}
  var values = $A(array);
  // show updated values in result layer (block)
  this._populate_list(result, values); 
  }
*/
////////////////////////////////
//
// a date picker popup
//
Popup.Date = Class.create(Popup.Base, {
    initialize: function($super, element, options) {
        $super(element, options);

        this._date = { yyyy:0, mm:0, dd:0 };
        this._template = new Template(this._options.date_format || Popup.DATE_FORMAT);

        if (this._hidden_field) {
            var d = $F(this._hidden_field);
            var match = d.match(this._options.date_regexp || Popup.DATE_REGEXP);
            $A(this._options.date_order || Popup.DATE_ORDER).each(function(x,index) {
                this._date[x] = match[index+1];
            }, this);
            // console.log('match: ' + $A(match).inspect() +
            //             ', date=' + $H(this._date).toQueryString() +
            //             ', string=' + this._format_date());
        }
    },

    // convert internal format into string
    _format_date: function() {
        return this._template.evaluate(this._date);
    },

    _draw_month: function(yyyy,mm,dd) { // jan = 1, dec = 12 !
        var date = new Date(yyyy,mm-1,1,12);
        var day = date.getDay() || 7; // mon = 1, ... sunday 0 => 7

        var nr_days = 31;
        if (mm == 4 || mm == 6 || mm == 9 || mm == 11) {
            nr_days = 30;
        } else if (mm == 2) {
            nr_days = 28;
            if (((yyyy % 4 == 0) && (yyyy % 100 != 0)) || (yyyy % 400 == 0)) {
                nr_days = 29;
            }
        }

        var row = 0, col = 1;  // current row and col
        var printDay = 1;
        var html = '<table>';

        // parse to decimal numbers
        mm   = parseInt(mm, 10);
        yyyy = parseInt(yyyy,10);
        
        var month_prev = mm - 1;
        var month = mm;
        var month_next = eval(mm + 1);
        var year_prev = yyyy - 1;
        var mp_year = yyyy;
        var mn_year = yyyy;
        var year_next = eval(yyyy + 1);

        if (month_prev == 0) { // previous year
             month_prev = 12;
             mp_year--;
        }
        if (month_next == 13) { // next year 
             month_next = 1;
            mn_year = eval(mn_year + 1);
        }

        var tr_start_date = '<tr class="date_row">';
        var tr_start = '<tr>';
        var tr_end = '</tr>';
        var th_3_start_month = '<th colspan="3" align="left" month="';
        var th_3_start = '<th colspan="3" align="left">';
        var th_4_start = '<th colspan="4" align="right">';
        var th_3_start_close = '">';
        var th_start = '<th>';
        var th_end = '</th>';
        var date_display_span = '<span class="date_display">';
        var span_end = '</span>';
        var img_prev_start = '<img class="prev" src="/images/resultset_previous.png" month="';
        var img_next_start = '<img class="next" src="/images/resultset_next.png" month="';
        var img_mid = '" year="';
        var img_end = '" />';
        
        html += tr_start_date;
            //html += th_3_start_month + mm + th_3_start_close;
            html += th_3_start;
                html += img_prev_start + month_prev + img_mid + mp_year + img_end;
                html += date_display_span + mm + span_end;
                html += img_next_start + month_next + img_mid + mn_year + img_end;
            html += th_end;
            html += th_4_start;
                html += img_prev_start + month + img_mid + year_prev + img_end;
                html += date_display_span + yyyy + span_end;
                html += img_next_start + month + img_mid + year_next + img_end;
            html += th_end;
        html += tr_end;
        html += tr_start;
        
        $A(this._options.date_days || Popup.DATE_DAYS).each(function(x) {
            html += th_start + x + th_end;
        }, this);

        html += tr_end;
        
        // pre-fill first line until current day
        while (col < day) {
            html += '<td></td>';
            col++;
        }

        // insert all others
        while (nr_days > 0) {
            var day = printDay;
            var mon = mm;
            var day_length = String(printDay).length;
            var mon_length = String(mm).length;
            if (day_length < 2) {
                day = '0'+ day;
            }
            if (mon_length < 2) {
                mon = '0'+ mon;
            }
            html += '<td align="right" name="'+ yyyy +'-'+ mon +'-'+ day +'" class="_date day">' + printDay + '</td>';
            nr_days--;
            printDay++;
            if (++col > 7) {
                html += '</tr>';
                col = 1;
                row++;
                if (nr_days > 0) {
                    html += '<tr>';
                } else {
                    col = -1;
                }
            }
        }

        // fill last line
        if (col >= 0) {
            while (col <= 7) {
                html += '<td></td>';
                col++;
            }
            html += '</tr>';
        }
        html += '</table>';
        this._popup.update(html);
    },

    onOpen: function() {
        this._draw_month(this._date.yyyy, this._date.mm, this._date.dd);
    },

    onPopupClick: function(e) {
        //console.log('onPopupClick');
        var new_month, new_year;
        if (e.target.tagName.toUpperCase() == 'IMG') { // clicked prev/next button -> set month/year + new draw
            if (Element.hasClassName(e.target,'next')) { // clicked next button
                // console.log('next:'+Element.readAttribute(e.target,'month')+'/'+Element.readAttribute(e.target,'year'));
                new_month = Element.readAttribute(e.target,'month');
                new_year = Element.readAttribute(e.target,'year');
            } else if (Element.hasClassName(e.target,'prev')) { // clicked prev button
                // console.log('prev:'+Element.readAttribute(e.target,'month')+'/'+Element.readAttribute(e.target,'year'));
                new_month = Element.readAttribute(e.target,'month');
                new_year = Element.readAttribute(e.target,'year');
            }
            if (new_month == 0) { // previous year
                new_month = 12;
                new_year--;
            } else if (new_month == 13) { // next year 
                new_month = 1;
                new_year++;
            }
              
            this._date.yyyy = new_year;
            this._date.mm   = new_month;
            //this._draw_month(new_year, new_month, this._date.dd);
            this._draw_month(this._date.yyyy, this._date.mm, this._date.dd);
            //this._format_date();
            //this._popup.update(html);
        //} else if (e.target.tagName.toUpperCase() == 'LI') {
            // clicked on a list entry
        //  this.setValue(e.target.innerHTML, Element.readAttribute(e.target,'value'));
           // this.doHide();
        } else if ((e.target.tagName.toUpperCase() == 'TD') && (Element.hasClassName(e.target,'_date'))) {
                //console.log('check');
                // clicked on a date
                this.setValue(Element.readAttribute(e.target,'name'), Element.readAttribute(e.target,'name'));
                //this._text = e.target.readAttribute('value');
                //console.log('InnerText='+e.target.readAttribute('name'));
                this.doHide();
        } else {
            //console.log('no no check');
        }
    }
});

//
// initiate Widgets
//

if (Traverser) {
    // Traverser.add('xxx', 'Popup.ClassName');
}
