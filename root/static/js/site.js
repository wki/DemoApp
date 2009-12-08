/*
default.js

standard utilities to control the entire site
*/

//
// Traverser is a singleton class
// traverses parts of the DOM and enhances all class="_xxx" marked things
// based on a lookup table that may get dynamically expanded
//
var Traverser = new (Class.create({
    //
    // constructor
    //
    initialize: function(){
        this._lookup = {};
    },

    //
    // prepare a part of the DOM tree
    //
    prepareDOM: function(e) {
        e = e || document;
        
        // local copy to avoid context-switching (20-30% faster)
        var lookup = this._lookup;

        //
        // find all tags that are of a class that starts with '_'
        // the first selector finds all classes that have a '_' anywhere
        // more filtering inside the loop
        //
        Element.select(e,'[class*="_"]').each(function(element) {
            //
            // go thru all classNames of this single tag
            // that start with '_'
            //
            // console.log('found: ' + element.className);
            $w(element.className).grep(/^_/).each(function(classname) {
                //
                // split this name into nonempty junks divded by '_'
                //
                var parts    = classname.split(/_/).grep(/./);
                var selector = parts.shift();

                //
                // try to make our object
                // and silently ignore any errors
                //
                try {
                    new lookup[selector](element, parts);
                } catch (exception) {
                    // alert(exception);
                    // simply ignore the exception
                }
            });
        });
    },

    //
    // add a new selector
    //
    add: function(selector, classname) {
        this._lookup[selector] = classname;
    },

    //
    // remove a lookup entry again
    //
    remove: function(selector) {
        delete this._lookup[selector];
    }
}))();

//
// the Util namespace
//
var Util = {};

//
// Util.FieldFocus -- focus a field with a minimal delay
//
Util.FieldFocus = Class.create({
    initialize: function(e) {
        if (e.tagName.toUpperCase() != 'INPUT') return;

        (function(f) {
            try {
                f.focus() 
            } catch(e) {
                // do nothing -- focus silently fails...
            }
        }).delay(0.5, e);
    }
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
                             parameters: this._form.serialize()
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
// Util.TableSort -- create sortable tables using TableKit
//
Util.TableSort = Class.create({
    initialize: function(e) {
        if (e.tagName.toUpperCase() != 'TABLE') return;
        if (!window['TableKit']) return;

        // console.log('new sortable: ' + e);
        TableKit.Sortable.init(e);
    }
});

//
// a drag and drop hierarchy
//
Util.Hierarchy = Class.create({
    initialize: function(e) {
        this._container = $(e);
        this._container.observe('click', this.onClick.bindAsEventListener(this));
    },
    
    onClick: function(e) {
        if (e.target.tagName.toUpperCase() != 'LI') return;
        
        Element.toggleClassName(e.target, 'expanded');
        e.stop();
    }
});

//
// image browser
//
Util.ImageField = Class.create({
    initialize: function(e, parts) {
        this._field = $(e);
        this._path = parts.join('/');
        console.log('new ImageField: ' + e + ', path=' + this._path);
        
        this._container = new Element('div', {style: 'position: absolute; display: inline; left: auto; top: auto; width: 1px; height: 1px;'});
        this._button = new Element('button').insert('...');
        
        this._button.observe('click', this.onButtonClick.bindAsEventListener(this));
        this._container.observe('click', this.onContainerClick.bindAsEventListener(this));
        e.insert({after: this._button});
        e.insert({after: this._container});
    },
    
    onButtonClick: function(e) {
        e.stop();
        console.log('button clicked...');
        
        // TODO: open popup, fill with ajax request, show directory, allow upload...
        new Ajax.Updater(this._container, 
                         '/products/ajax/choose_image/' + this._path,
                         {});
        // TODO: after loading find 'img._loader' image and hook form.submit() to displaying it
    },
    
    onContainerClick: function(e) {
        var target =$(e.target);
        if (target.hasClassName('clickable')) {
            console.log('clickable was clicked.');
            this._field.value = Element.readAttribute(target,'value');
            e.stop();
            this._container.innerHTML = '';
        } else if (target.hasClassName('expandable')) {
            target.toggleClassName('expanded');
        } else if (target.hasClassName('close')) {
            e.stop();
            this._container.innerHTML = '';
        }
        
    }
});

//
// initiate Utils
//
Traverser.add('update',    Util.FormUpdater);
Traverser.add('enhance',   Util.FormEnhancer);
Traverser.add('focus',     Util.FieldFocus);
Traverser.add('sortable',  Util.TableSort);
Traverser.add('hierarchy', Util.Hierarchy);
Traverser.add('image',     Util.ImageField);

document.observe('dom:loaded', function() {
    Traverser.prepareDOM(document);
});

//
// disable auto-loading of table-kit (slooooow on IE)
//
if (window['TableKit']) {
    TableKit.options.autoLoad = false;
}

