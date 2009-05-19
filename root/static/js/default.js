/*
default.js

standard utilities to control the entire site
*/

//
// the Site-Util master class...
//
var Util = {};
var SiteUtil = Class.create({
    //
    // constructor
    //
    initialize: function() {
        this.prepareDOM(document);
    },
    
    //
    // prepare unobtrusive things under a given element
    //
    prepareDOM: function(element) {
        if (!element) { element = document; }
        
        Element.select(element, 'form[class^=_update_]').each(function(e) {
            new Util.FormUpdater(e);
        });

        Element.select(element, 'form[class^=_enhance]').each(function(e) {
            new Util.FormEnhancer(e);
        });
     
        //
        // if we find a field marked '_focus' --> activate it with minimal delay
        //
        this.focusField(Element.down(element, 'input[class=_focus]')).defer();
    },
    
    //
    // helper: focus a field
    //
    focusField: function(f) {
        if (f) f.focus();
    },
    
    //
    // last entry
    //
    _dummy: 0
});

//
// Util.FormEnhancer -- magic things for FormFu Forms
//
Util.FormEnhancer = Class.create({
    //
    // constructor
    //
    initialize: function(e) {
        this._form = e;
        
        // check if we have repeatable things
        var repeatables = e.select('div[class*=_repeat_]');
        var groups = repeatables.map(function(x) {
            return $w(x.className).grep(/^_repeat_/).first().replace(/^_repeat_/,'');
        }).uniq();
        console.log('found ' + repeatables.length + ' repeatables: ' + groups.join(', '));
        
        // for every group do
        //   - find all rows in repeatables
        //   - find the count 'hidden' field
        //   - add a 'delete' button to every regular row
        //   - add a 'add' button after last row
        //   - save the HTML for an empty row (the last one)
        
        this._groups = $H({});
        groups.each(function(g) {
            console.log('group = ' + g);
            
            // collect all rows inside the repeatable
            var rows = repeatables.select(function(x) {
                return x.hasClassName('_repeat_' + g);
            });
            
            if (!rows || rows.length == 0) return;
            
            var class_name = rows[0].className;
            
            // add the '-' button
            rows.each(function(r) { this.addMinusButton(r); }, this);
            
            // find the count_field
            var count_field = e.down('input[name="' + g +'"]');
            var count = $F(count_field);
            
            // get the template html
            var html = rows[rows.length-1].innerHTML;
            // html = orig_html.gsub(/name="[^"]+_\d+"/)

            // prepare a blank row with a '+' button
            //   and add it after the last row
            var button_add = new Element('img', 
                                         {'src':   '/static/images/add.png',
                                          'class': 'button _add'});
            var add_row = new Element('div', {'class': class_name});
            add_row.insert(button_add);
            rows[rows.length-1].insert({after: add_row});
            
            // remove the last row (assume 1 empty row)
            Element.remove(rows.pop());
            
            console.log('nr_rows = ' + $F(count_field));
            console.log('html =' + html);
            
            // save the group
            this._groups.set(g,
                             {count_field:   count_field,
                              filled_rows:   rows,
                              new_rows:      [],
                              add_row:       add_row,
                              class_name:    class_name,
                              template_html: html});
            console.log('group ' + g + ': ' + $H(this._groups.get(g)).inspect());
            
            this.updateRepeatableFields(g);
        }, this);
        
        e.observe('click', this.onClick.bindAsEventListener(this));
    },
    
    //
    // helper: add a '-' Button to a repeatable element
    //
    addMinusButton: function(div) {
        Element.insert(div,
                       new Element('img', 
                                   {'src':   '/static/images/delete.png',
                                    'class': 'button _del'})
                      );
    },
    
    //
    // helper: clean up code in new rows and update the 'count' hidden field
    //
    updateRepeatableFields: function(group_name) {
        var group = this._groups.get(group_name);
        if (!group) return;
        
        // scan all fields but skip real DB-fields
        var i = group.filled_rows.length+1; // first "index" of an empty repeatable
        group.new_rows.each(function(r) {
            // replace all field names
            r.select('[name]').each(function(e) {
                console.log(e);
                var name = e.readAttribute('name');
                if (name.match(/_[0-9]+$/)) {
                    console.log(' --> ' + name.sub(/_[0-9]+$/, '_' + i));
                    e.writeAttribute('name', name.sub(/_[0-9]+$/, '_' + i));
                }
            });
            i++;
        });
     
        // update count-field
        group.count_field.value = group.filled_rows.length + group.new_rows.length;
        
        console.log('update complete, rows = ' + (group.filled_rows.length + group.new_rows.length));
    },
    
    //
    // click handler
    //
    onClick: function(e) {
        if (e.target.tagName.toUpperCase() != 'IMG') return;
        
        console.log(e.target.tagName);
        
        var t = e.target;
        if (Element.hasClassName(t,'_add')) {
            // find the group
            var repeatable = Element.up(t, 'div[class*=_repeat_]');
            if (!repeatable) return;

            var group_name = $w(repeatable.className).grep(/^_repeat_/).first().replace(/^_repeat_/,'');
            if (!group_name || !this._groups.get(group_name)) return;
            
            var group = this._groups.get(group_name);
            
            // build the repeatable div to insert
            var div = new Element('div', {'class': group.class_name});
            Element.insert(div, group.template_html);
            this.addMinusButton(div);
            Element.insert(group.add_row, {before: div});

            // add a nice effect...
            Element.setStyle(div,{'minHeight': '0px'});
            new Effect.BlindDown(div, {duration: 0.2});
            
            group.new_rows.push(div);
            this.updateRepeatableFields(group_name);
            
            e.stop();
        } else if (Element.hasClassName(t,'_del')) {
            // find the group
            var repeatable = Element.up(t, 'div[class*=_repeat_]');
            if (!repeatable) return;
            
            var group_name = $w(repeatable.className).grep(/^_repeat_/).first().replace(/^_repeat_/,'');
            if (!group_name || !this._groups.get(group_name)) return;

            // find out if this row is a DB-row or an added one...
            var group = this._groups.get(group_name);
            
            // setup a dummy action to fire after effect finishes
            var action = function() {};
            
            if (group.filled_rows.include(repeatable)) {
                // the row was a DB row -- must set the hidden field
                var del = Element.down(repeatable, 'input[name*=".del_"]');
                if (!del) {
                    console.log('no delete button found - strange');
                } else {
                    del.checked = true;
                }
            } else if (group.new_rows.include(repeatable)) {
                // the row was a new row -- simply delete (deferred...)
                action = (function() {
                    Element.remove(repeatable);
                    group.new_rows = group.new_rows.without(repeatable);
                    this.updateRepeatableFields(group_name);
                }).bind(this);
            } else {
                // row is not identifyable -- strange
                console.log('unknown row...');
                e.stop();
            }
            
            Element.setStyle(repeatable,{'minHeight': '0px'});
            new Effect.BlindUp(repeatable, {duration: 0.2, afterFinish: action});
            e.stop();
        }
    },
    
    //
    // last entry
    //
    _dummy: 0
});

//
// Util.FormUpdater - update a div tag upon submit
//
Util.FormUpdater = Class.create({
    //
    // constructor
    //
    initialize: function(e) {
        this._form = e;
        
        var div = $w(e.className).grep(/^_update_/).first().replace(/^_update_/,'');
        
        this._div = $(div);
        e.observe('submit', this.onSubmit.bindAsEventListener(this));
    },
    
    //
    // form submission
    //
    onSubmit: function(e) {
        var curtain = new Element('div', 
                                 {
                                     'class': 'loading',
                                     'style': 'width: '  + this._div.getWidth()  + 'px;' +
                                              'height: ' + this._div.getHeight() + 'px;'
                                  });
        /* 
        var inside = new Element('div');
        inside.update(img);
        inside.setStyle({width: update_div.getWidth() + 'px', height: update_div.getHeight() + 'px'});
        inside.wrap(curtain); 
        */
        this._div.insert({top: curtain});
        console.log('will update: ' + this._div);
        new Ajax.Updater(this._div,
                         this._form.readAttribute('action'),
                         {
                             evalScripts: true,
                             parameters: this._form.serialize(),
                             // onComplete: ... something maybe...
                         });
        e.stop();
    },
    
    //
    // last entry
    //
    _dummy: 0
});

//
// initiate Utils
//
var siteutil;
document.observe('dom:loaded', function() {
    siteutil = new SiteUtil();
});
