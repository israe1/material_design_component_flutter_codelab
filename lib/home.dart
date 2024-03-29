// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import 'package:Shrine/supplemental/asymmetric_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model/products_repository.dart';
import 'model/product.dart';

class HomePage extends StatelessWidget {
  // TODO: Make a collection of cards (102)
  // TODO: Add a variable for Category (104)
  final Category category;

  const HomePage({this.category = Category.all});

  @override
  Widget build(BuildContext context) {
    // TODO: Return an AsymmetricView (104)
    // TODO: Pass Category variable to AsymmetricView (104)
    return AsymmetricView(
        products: ProductsRepository.loadProducts(category),
      );
  }

  gridView(BuildContext context){
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.0),
      childAspectRatio: 8.0 / 9.0,
      children: _buildGridCards(context),
    );
  }

  appBar(){
    return AppBar(
      brightness: Brightness.light,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          semanticLabel: 'menu',
        ),
        onPressed: (){
          print('Menu button');
        },
      ),
      title: Text('SHRINE'),
      actions: [
        IconButton(
            icon: Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: (){
              print('Search button');
            }
        ),
        IconButton(
            icon: Icon(
              Icons.tune,
              semanticLabel: 'filter',
            ),
            onPressed: (){
              print('Filter button');
            }
        ),
      ],
    );
  }
  
  List<Card> _buildGridCards(BuildContext context){
    List<Product> products = ProductsRepository.loadProducts(Category.all);

    if(products == null || products.isEmpty){
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString()
    );
    return products.map((e){
      return Card(
        elevation: 4.0,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 18 / 11,
              child: Image.asset(
                e.assetName,
                fit: BoxFit.fitWidth,
                package: e.assetPackage,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      e == null ? '' : e.name,
                      style: theme.textTheme.headline6,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.0,),
                    Text(
                      e == null ? '' : formatter.format(e.price),
                      style: theme.textTheme.subtitle2,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }).toList();
  }
}
