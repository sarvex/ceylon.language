function OpenClass$jsint(pkg, meta, that){
    if (meta===undefined)throw new Error("Class reference not found. Metamodel doesn't work with modules compiled in lexical scope style");
    $init$OpenClass$jsint();
    if (that===undefined)that=new OpenClass$jsint.$$;
    that.pkg_ = pkg;
    var _mm=getrtmm$$(meta);
    if (_mm === undefined) {
      //it's a metamodel
      that.meta_=meta;
      that.tipo=_findTypeFromModel(pkg,meta);
      _mm = getrtmm$$(that.tipo);
    } else {
      //it's a type
      that.tipo = meta;
      that.meta_ = get_model(_mm);
    }
    that.name_=(that.meta&&that.meta.nm)||_mm.d[_mm.d.length-1];
    that.toplevel_=_mm.$cont===undefined;
    ClassDeclaration$meta$declaration(that);
    return that;
}
