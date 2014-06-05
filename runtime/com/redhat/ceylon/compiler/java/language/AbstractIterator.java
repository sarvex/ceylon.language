package com.redhat.ceylon.compiler.java.language;

import ceylon.language.Iterator;

import com.redhat.ceylon.compiler.java.metadata.Ceylon;
import com.redhat.ceylon.compiler.java.metadata.Class;
import com.redhat.ceylon.compiler.java.metadata.Ignore;
import com.redhat.ceylon.compiler.java.runtime.model.ReifiedType;
import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

@Ceylon(major = 7)
@Class(extendsType="ceylon.language::Object")
public abstract class AbstractIterator<Element> implements Iterator<Element>, ReifiedType {
    
    @Ignore
    private TypeDescriptor $reifiedElement;

    public AbstractIterator(@Ignore TypeDescriptor $reifiedElement) {
        this.$reifiedElement = $reifiedElement;
    }
    
    @Override
    @Ignore
    public TypeDescriptor $getType$() {
        return TypeDescriptor.klass(AbstractIterator.class, $reifiedElement);
    }
}
