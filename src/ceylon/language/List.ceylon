import ceylon.language.meta { type }
"""Represents a collection in which every element has a 
   unique non-negative integer index.
   
   A `List` is a [[Collection]] of its elements, and a 
   [[Correspondence]] from indices to elements.
   
   Direct access to a list element by index produces a value 
   of optional type. The following idiom may be used instead 
   of upfront bounds-checking, as long as the list element 
   type is a non-`null` type:
   
       if (exists char = "hello world"[index]) { 
           //do something with char
       }
       else {
           //out of bounds
       }
   
   When an algorithm guarantees that a list contains a given 
   index, the following idiom may be used:
   
       assert (exists char = "hello world"[index]);
       //do something with char
   
   To iterate the indices of a `List`, use the following
   idiom:
   
       for (i->char in "hello world".indexed) { ... }
   
   [[Strings|String]], [[sequences|Sequential]], 
   [[tuples|Tuple]], and [[arrays|Array]] are all `List`s,
   and are all of fixed length. Variable-length mutable
   `List`s are also possible."""
see (`interface Sequence`, 
     `interface Empty`, 
     `class Array`)
shared interface List<out Element>
        satisfies Collection<Element> &
                  Correspondence<Integer,Element> &
                  Ranged<Integer,Element,List<Element>> {
    
    "The index of the last element of the list, or `null` if 
     the list is empty."
    see (`value List.size`)
    shared formal Integer? lastIndex;
    
    "The number of elements in this list, always
     `list.lastIndex+1`."
    see (`value List.lastIndex`)
    shared actual default Integer size 
            => (lastIndex else -1) + 1;
    
    shared actual default Boolean shorterThan(Integer length) 
            => size<length;
    
    shared actual default Boolean longerThan(Integer length) 
            => size>length;
    
    "The rest of the list, without the first element."
    shared actual default List<Element> rest => Rest(1);
    
    "Determines if the given index refers to an element of 
     this list, that is, if `0<=index<=list.lastIndex`."
    shared actual default Boolean defines(Integer index) 
            => 0 <= index <= (lastIndex else -1);
    
    "Returns the element of this sequence with the given
     index if the index refers to an element of the list,
     that is, if `0<=index<=list.lastIndex`, or `null` 
     otherwise. The first element of the list has index 
     `0`."
    shared formal Element? elementAt(Integer index);
	
	shared actual Element? get(Integer index) => elementAt(index);
    
    shared actual default Iterator<Element> iterator() {
        object listIterator
                satisfies Iterator<Element> {
            variable Integer index = 0;
            shared actual Element|Finished next() {
                if (exists max=lastIndex, index<=max) {
                    assert (is Element element 
                        = elementAt(index++));
                    return element;
                }
                else {
                    return finished;
                }
            }
        }
        return listIterator;
    }
    
    "A list containing the elements of this list in reverse 
     order."
    shared default List<Element> reversed => Reversed();
    
    "Two `List`s are considered equal iff they have the 
     same `size` and _entry sets_. The entry set of a list 
     `list` is the set of elements of `list.indexed`. This 
     definition is equivalent to the more intuitive notion 
     that two lists are equal iff they have the same `size` 
     and for every index either:
     
     - the lists both have the element `null`, or
     - the lists both have a non-null element, and the
       two elements are equal.
     
     As a special exception, a [[String]] is not equal to 
     any list which is not also a [[String]]."
    shared actual default Boolean equals(Object that) {
        if (is String that) {
            return false;
        }
        if (is List<Anything> that) {
            if (that.size==size) {
                for (i in 0..size-1) {
                    value x = elementAt(i);
                    value y = that.elementAt(i);
                    if (exists x) {
                        if (exists y) {
                            if (x!=y) {
                                return false;
                            }
                        }
                        else {
                            return false;
                        }
                    }
                    else if (exists y) {
                        return false;
                    }
                }
                else {
                    return true;
                }
            }
        }
        return false;
    }
    
    shared actual default Integer hash {
        variable value hash = 1;
        for (elem in this) {
            hash *= 31;
            if (exists elem) {
                hash += elem.hash;
            }
        }
        return hash;
    }
    
    shared default actual Element? findLast(
            Boolean selecting(Element elem)) {
        if (exists endIndex=lastIndex) {
            variable value index = endIndex;
            while (index >= 0) {
                if (exists elem = elementAt(index--)) {
                    if (selecting(elem)) {
                        return elem;
                    }
                }
            }
        }
        return null;
    }
    
    "Returns the first element of this `List`, if any."
    shared actual default Element? first => elementAt(0);
    
    "Returns the last element of this `List`, if any."
    shared actual default Element? last {
        if (exists endIndex = lastIndex) {
            return elementAt(endIndex);
        }
        else {
            return null;
        }
    }
    
    "A list containing all indexes of this list."
    shared actual default List<Integer> keys => Indexes();
    
    "Returns a new `List` that starts with the specified
     element, followed by the elements of this list."
    see (`function following`)
    shared default [Other|Element+] withLeading<Other>(
            "The first element of the resulting sequence."
            Other element)
            => [*(Singleton(element) chain this)];
    
    "Returns a new `List` that contains the specified
     element appended to the end of the elements of this 
     list."
    shared default [Element|Other+] withTrailing<Other>(
            "The last element of the resulting sequence."
            Other element)
            => [*(this chain Singleton(element))];
    
    "Determine if the given list occurs at the start of this 
     list."
    shared default Boolean startsWith(List<Anything> sublist)
            => includesAt(0, sublist);
    
    "Determine if the given list occurs at the end of this 
     list."
    shared default Boolean endsWith(List<Anything> sublist)
            => includesAt(size-sublist.size, sublist);
    
    "Determine if the given list occurs at the given index 
     of this list."
    shared default Boolean includesAt(
            "The index at which the [[sublist]] might occur."
            Integer index, 
            List<Anything> sublist) {
        for (i in 0:sublist.size) {
            value x = elementAt(index+i);
            value y = sublist.elementAt(i);
            if (exists x) {
                if (exists y) {
                    if (x!=y) {
                        return false;
                    }
                }
                else {
                    return false;
                }
            }
            else if (exists y) {
                return false;
            }
        }
        else {
            return true;
        }
    }
    
    "Determine if the given list occurs at some index in 
     this list."
    shared default Boolean includes(List<Anything> sublist) {
        for (index in 0:size) {
            if (includesAt(index,sublist)) {
                return true;
            }
        }
        return false;
    }
    
    "The indexes in this list at which the given list 
     occurs."
    shared default {Integer*} inclusions(List<Anything> sublist) 
            => { for (index in 0:size) 
                    if (includesAt(index,sublist)) index };
    
    "The first index in this list at which the given list 
     occurs."
    shared default Integer? firstInclusion(List<Anything> sublist) {
        for (index in 0:size) {
            if (includesAt(index,sublist)) {
                return index;
            }
        }
        else {
            return null;
        }
    }
    
    "The last index in this list at which the given list 
     occurs."
    shared default Integer? lastInclusion(List<Anything> sublist) {
        for (index in (0:size).reversed) {
            if (includesAt(index,sublist)) {
                return index;
            }
        }
        else {
            return null;
        }
    }
    
    "Determines if the given value occurs at the given index 
     in this list."
    shared default Boolean occursAt(
            "The index at which the value might occur."
            Integer index, 
            Anything element) {
        value elem = elementAt(index);
        if (exists element) {
            if (exists elem) {
                return elem==element;
            }
            else {
                return false;
            }
        }
        else {
            return !elem exists;
        }
    }
    
    "Determines if the given value occurs as an element of 
     this list."
    shared default Boolean occurs(Anything element) {
        for (index in 0:size) {
            if (occursAt(index,element)) {
                return true;
            }
        }
        return false;
    }
    
    "Determines if this list contains the given value.
     Returns `true` for every element of this list."
    see (`function occurs`)
    shared actual default Boolean contains(Object element) 
            => occurs(element);
        
    "The indexes in this list at which the given element 
     occurs."
    shared default {Integer*} occurrences(Anything element)
            => { for (index in 0:size) 
                    if (occursAt(index,element)) index };
    
    "The first index in this list at which the given element 
     occurs."
    shared default Integer? firstOccurrence(Anything element) {
        for (index in 0:size) {
            if (occursAt(index,element)) {
                return index;
            }
        }
        else {
            return null;
        }
    }
    
    "The last index in this list at which the given element 
     occurs."
    shared default Integer? lastOccurrence(Anything element) {
        for (index in (0:size).reversed) {
            if (occursAt(index,element)) {
                return index;
            }
        }
        else {
            return null;
        }
    }
        
    "The indexes in this list for which the element 
     satisfies the given [[predicate function|selecting]]."
    shared default {Integer*} indexesWhere(
            "The predicate the indexed elements must 
             satisfy"
            Boolean selecting(Element element)) 
            => { for (index in 0:size) 
                    if (is Element element=elementAt(index), 
                            selecting(element)) 
                        index };
    
    "The first index in this list for which the element 
     satisfies the given [[predicate function|selecting]]."
    shared default Integer? firstIndexWhere(
            "The predicate the indexed elements must 
             satisfy"
            Boolean selecting(Element element)) {
        variable value index = 0;
        while (index<size) {
            assert (is Element element=elementAt(index));
            if (selecting(element)) {
                return index;
            }
            index++;
        }
        return null;
    }
    
    "The last index in this list for which the element 
     satisfies the given [[predicate function|selecting]]."
    shared default Integer? lastIndexWhere(
            "The predicate the indexed elements must 
             satisfy"
            Boolean selecting(Element element)) {
        variable value index = size;
        while (index>0) {
            index--;
            assert (is Element element=elementAt(index));
            if (selecting(element)) {
                return index;
            }
        }
        return null;
    }
    
    "Trim the elements satisfying the given [[predicate 
     function|trimming]] from the start and end of this list, 
     returning a list no longer than this list."
    shared default List<Element> trim(Boolean trimming(Element elem)) {
        if (exists end=lastIndex) {
            variable Integer from=-1;
            variable Integer to=-1;
            for (index in 0..end) {
                assert (is Element elem=elementAt(index));
                if (!trimming(elem)) {
                    from = index;
                    break;
                }
            }
            else {
                return [];
            }
            for (index in end..0) {
                assert (is Element elem=elementAt(index));
                if (!trimming(elem)) {
                    to = index;
                    break;
                }
            }
            else {
                return [];
            }
            return this[from..to];
        }
        else {
            return [];
        }
    }
    
    "Trim the elements satisfying the given [[predicate 
     function|trimming]] from the start of this list, 
     returning a list no longer than this list."
    shared default List<Element> trimLeading(Boolean trimming(Element elem)) {
        if (exists end=lastIndex) {
            for (index in 0..end) {
                assert (is Element elem=elementAt(index));
                if (!trimming(elem)) {
                    return this[index..end];
                }
            }
        }
        return [];
    }
    
    "Trim the elements satisfying the given [[predicate 
     function|trimming]] from the end of this list, 
     returning a list no longer than this list."
    shared default List<Element> trimTrailing(Boolean trimming(Element elem)) {
        if (exists end=lastIndex) {
            for (index in end..0) {
                assert (is Element elem=elementAt(index));
                if (!trimming(elem)) {
                    return this[0..index];
                }
            }
        }
        return [];
    }
    
    "Select the first elements of this list, returning a 
     list no longer than the given length. If this list is 
     shorter than the given length, return this list. 
     Otherwise return a list of the given length."
    see (`function List.terminal`)
    shared default List<Element> initial(Integer length)
            => this[0:length];
    
    "Select the last elements of the list, returning a list 
     no longer than the given length. If this list is 
     shorter than the given length, return this list. 
     Otherwise return a list of the given length."
    see (`function List.initial`)
    shared default List<Element> terminal(Integer length) {
        if (exists end = lastIndex, length>0) {
            return this[end-length+1..end];
        }
        else {
            return [];
        }
    }
    
    //TODO: enable when backend bug is fixed
    //"Return two lists, the first containing the elements
    // that occur before the given [[index]], the second with
    // the elements that occur after the given `index`. If the
    // given `index` is outside the range of indices of this
    // list, one of the returned lists will be empty."
    //shared default [List<Element>,List<Element>] slice(Integer index)
    //    => [this[...index-1], this[index...]];
    
    shared actual formal List<Element> clone();
    
    
    class Indexes()
            extends Object()
            satisfies List<Integer> {
        
        lastIndex => outer.lastIndex;
        
        elementAt(Integer index) 
                => defines(index) then index;
        
        segment(Integer from, Integer length)
                => clone()[from:length];
        
        clone() => 0:size;
        
        span(Integer from, Integer to)
                => clone()[from..to];
        spanFrom(Integer from) => clone()[from...];
        spanTo(Integer to) => clone()[...to];
        
        shared actual String string {
            if (exists lastIndex) {
                return "{ 0, ... , ``lastIndex`` }";
            }
            else {
                return "{}";
            }
        }
        
        shared actual Iterator<Integer> iterator() {
            object iterator satisfies Iterator<Integer> {
                variable value i=0;
                shared actual Integer|Finished next() {
                    if (i<size) {
                        return i++;
                    }
                    else {
                        return finished;
                    }
                }
            }
            return iterator;
        }
        
    }
    
    class Rest(Integer from)
            extends Object()
            satisfies List<Element> {
        
        assert (from>=0);
        
        shared actual Element? elementAt(Integer index) {
            if (index<0) {
                return null;
            }
            else {
                return outer.elementAt(index+from);
            }
        }
        
        shared actual Integer? lastIndex {
            value size = outer.size-from;
            return size>0 then size-1;
        }
        
        segment(Integer from, Integer length) 
                => outer[from+this.from:length];
        
        span(Integer from, Integer to) 
                => outer[from+this.from..to+this.from];
        spanFrom(Integer from) => outer[from+this.from...];
        spanTo(Integer to) => outer[this.from..to+this.from];
        
        clone() => outer.clone().Rest(from);
        
        shared actual Iterator<Element> iterator() {
            value iter = outer.iterator();
            variable value i=0;
            while (i++<from) {
                iter.next();
            }
            object iterator satisfies Iterator<Element> {
                next() => iter.next();
            }
            return iterator;
        }
        
    }
    
    class Reversed()
            extends Object()
            satisfies List<Element> {
        
        lastIndex => outer.lastIndex;
        
        shared actual Element? elementAt(Integer index) {
            if (exists lastIndex) {
                return outer.elementAt(lastIndex-index);
            }
            else {
                return null;
            }
        }
        
        shared actual List<Element> segment(Integer from, Integer length) {
            if (exists lastIndex, length>1) {
                value start = lastIndex-from;
                return outer[start..start-length+1];
            }
            else {
                return [];
            }
        }
        
        span(Integer from, Integer to) => outer[to..from];
        
        shared actual List<Element> spanFrom(Integer from) {
            if (exists lastIndex, from<=lastIndex) { 
                return outer[lastIndex-from..0];
            }
            else {
                return [];
            }
        }
        
        shared actual List<Element> spanTo(Integer to) {
            if (exists lastIndex, to>=0) { 
                return outer[lastIndex..lastIndex-to];
            }
            else {
                return [];
            }
        }
        
        clone() => outer.clone().reversed;
        
        shared actual Iterator<Element> iterator() {
            value outerList=outer;
            object iterator satisfies Iterator<Element> {
                variable value i=outerList.size-1;
                shared actual Element|Finished next() {
                    if (i>=0) {
                        assert (is Element elem = 
                            outerList.elementAt(i--));
                        return elem;
                    }
                    else {
                        return finished;
                    }
                }
            }
            return iterator;
        }
        
    }
    
}
