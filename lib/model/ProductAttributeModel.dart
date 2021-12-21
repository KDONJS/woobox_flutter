class ProductAttributeModel {
    List<Brand> brands;
    List<Category> categories;
    List<Color> colors;
    List<Size> sizes;

    ProductAttributeModel({this.brands, this.categories, this.colors, this.sizes});

    factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
        return ProductAttributeModel(
            brands: json['brands'] != null ? (json['brands'] as List).map((i) => Brand.fromJson(i)).toList() : null,
            categories: json['categories'] != null ? (json['categories'] as List).map((i) => Category.fromJson(i)).toList() : null,
            colors: json['colors'] != null ? (json['colors'] as List).map((i) => Color.fromJson(i)).toList() : null,
            sizes: json['sizes'] != null ? (json['sizes'] as List).map((i) => Size.fromJson(i)).toList() : null,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.brands != null) {
            data['brands'] = this.brands.map((v) => v.toJson()).toList();
        }
        if (this.categories != null) {
            data['categories'] = this.categories.map((v) => v.toJson()).toList();
        }
        if (this.colors != null) {
            data['colors'] = this.colors.map((v) => v.toJson()).toList();
        }
        if (this.sizes != null) {
            data['sizes'] = this.sizes.map((v) => v.toJson()).toList();
        }
        return data;
    }
}

class Size {
    int count;
    String description;
    String filter;
    String name;
    int parent;
    String slug;
    String taxonomy;
    int term_group;
    int term_id;
    int term_taxonomy_id;
    bool isSelected = false;

    Size({this.count, this.description, this.filter, this.name, this.parent, this.slug, this.taxonomy, this.term_group, this.term_id, this.term_taxonomy_id});

    factory Size.fromJson(Map<String, dynamic> json) {
        return Size(
            count: json['count'],
            description: json['description'],
            filter: json['filter'],
            name: json['name'],
            parent: json['parent'],
            slug: json['slug'],
            taxonomy: json['taxonomy'],
            term_group: json['term_group'],
            term_id: json['term_id'],
            term_taxonomy_id: json['term_taxonomy_id'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['count'] = this.count;
        data['description'] = this.description;
        data['filter'] = this.filter;
        data['name'] = this.name;
        data['parent'] = this.parent;
        data['slug'] = this.slug;
        data['taxonomy'] = this.taxonomy;
        data['term_group'] = this.term_group;
        data['term_id'] = this.term_id;
        data['term_taxonomy_id'] = this.term_taxonomy_id;
        return data;
    }
}

class Color {
    int count;
    String description;
    String filter;
    String name;
    int parent;
    String slug;
    String taxonomy;
    int term_group;
    int term_id;
    int term_taxonomy_id;
    bool isSelected = false;

    Color({this.count, this.description, this.filter, this.name, this.parent, this.slug, this.taxonomy, this.term_group, this.term_id, this.term_taxonomy_id});

    factory Color.fromJson(Map<String, dynamic> json) {
        return Color(
            count: json['count'],
            description: json['description'],
            filter: json['filter'],
            name: json['name'],
            parent: json['parent'],
            slug: json['slug'],
            taxonomy: json['taxonomy'],
            term_group: json['term_group'],
            term_id: json['term_id'],
            term_taxonomy_id: json['term_taxonomy_id'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['count'] = this.count;
        data['description'] = this.description;
        data['filter'] = this.filter;
        data['name'] = this.name;
        data['parent'] = this.parent;
        data['slug'] = this.slug;
        data['taxonomy'] = this.taxonomy;
        data['term_group'] = this.term_group;
        data['term_id'] = this.term_id;
        data['term_taxonomy_id'] = this.term_taxonomy_id;
        return data;
    }
}

class Category {
    int cat_ID;
    String cat_name;
    int category_count;
    String category_description;
    String category_nicename;
    int category_parent;
    int count;
    String description;
    String filter;
    String name;
    int parent;
    String slug;
    String taxonomy;
    int term_group;
    int term_id;
    int term_taxonomy_id;
    bool isSelected = false;

    Category({this.cat_ID, this.cat_name, this.category_count, this.category_description, this.category_nicename, this.category_parent, this.count, this.description, this.filter, this.name, this.parent, this.slug, this.taxonomy, this.term_group, this.term_id, this.term_taxonomy_id});

    factory Category.fromJson(Map<String, dynamic> json) {
        return Category(
            cat_ID: json['cat_ID'],
            cat_name: json['cat_name'],
            category_count: json['category_count'],
            category_description: json['category_description'],
            category_nicename: json['category_nicename'],
            category_parent: json['category_parent'],
            count: json['count'],
            description: json['description'],
            filter: json['filter'],
            name: json['name'],
            parent: json['parent'],
            slug: json['slug'],
            taxonomy: json['taxonomy'],
            term_group: json['term_group'],
            term_id: json['term_id'],
            term_taxonomy_id: json['term_taxonomy_id'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['cat_ID'] = this.cat_ID;
        data['cat_name'] = this.cat_name;
        data['category_count'] = this.category_count;
        data['category_description'] = this.category_description;
        data['category_nicename'] = this.category_nicename;
        data['category_parent'] = this.category_parent;
        data['count'] = this.count;
        data['description'] = this.description;
        data['filter'] = this.filter;
        data['name'] = this.name;
        data['parent'] = this.parent;
        data['slug'] = this.slug;
        data['taxonomy'] = this.taxonomy;
        data['term_group'] = this.term_group;
        data['term_id'] = this.term_id;
        data['term_taxonomy_id'] = this.term_taxonomy_id;
        return data;
    }
}

class Brand {
    int count;
    String description;
    String filter;
    String name;
    int parent;
    String slug;
    String taxonomy;
    int term_group;
    int term_id;
    int term_taxonomy_id;
    bool isSelected = false;

    Brand({this.count, this.description, this.filter, this.name, this.parent, this.slug, this.taxonomy, this.term_group, this.term_id, this.term_taxonomy_id});

    factory Brand.fromJson(Map<String, dynamic> json) {
        return Brand(
            count: json['count'],
            description: json['description'],
            filter: json['filter'],
            name: json['name'],
            parent: json['parent'],
            slug: json['slug'],
            taxonomy: json['taxonomy'],
            term_group: json['term_group'],
            term_id: json['term_id'],
            term_taxonomy_id: json['term_taxonomy_id'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['count'] = this.count;
        data['description'] = this.description;
        data['filter'] = this.filter;
        data['name'] = this.name;
        data['parent'] = this.parent;
        data['slug'] = this.slug;
        data['taxonomy'] = this.taxonomy;
        data['term_group'] = this.term_group;
        data['term_id'] = this.term_id;
        data['term_taxonomy_id'] = this.term_taxonomy_id;
        return data;
    }
}