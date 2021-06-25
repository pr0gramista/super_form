import 'package:flutter/material.dart';
import 'package:super_form/super_form.dart';
import 'package:super_form_example/burritox/form.dart';
import 'package:super_form_example/burritox/model.dart';
import 'package:super_form_example/github_link.dart';
import 'package:super_form_example/result_dialog.dart';

import 'burrito_list.dart';

/// Entrypoint for Burritox Food Delivery demo
///
/// Shows how to build a universal form for adding and editing values.
/// There is the use of initial values, dynamic rules (order count) and
/// a custom form connected widget - [ChangeCountButton]
class Burritox extends StatefulWidget {
  const Burritox({Key? key}) : super(key: key);

  @override
  _BurritoxState createState() => _BurritoxState();
}

class _BurritoxState extends State<Burritox> {
  List<BurritoOrder> orders = [];
  GlobalKey<SuperFormState> formKey = GlobalKey<SuperFormState>();

  void _replaceOrAddOrder(BurritoOrder newOrder) {
    final sameBurritoOrderIndex =
        orders.indexWhere((element) => element.burrito == newOrder.burrito);

    if (sameBurritoOrderIndex == -1) {
      orders.add(newOrder);
    } else {
      // If we found an order with same burrito configured we want to merge the orders
      orders[sameBurritoOrderIndex] = BurritoOrder(
        burrito: orders[sameBurritoOrderIndex].burrito,
        count: orders[sameBurritoOrderIndex].count + newOrder.count,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  // https://unsplash.com/photos/50KffXbjIOg
                  image: AssetImage("burritox.jpg"),
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🌯 Burritox 🌯',
                        style: TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      const Text("Best virtual burritos in your hood!"),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: BurritoForm(
                          formKey: formKey,
                          onSubmit: (newOrder) {
                            setState(() {
                              _replaceOrAddOrder(newOrder);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            child: Column(children: [
              Expanded(
                  child: BurritoList(
                orders: orders,
                onSubmit: (oldOrder, newOrder) {
                  setState(() {
                    orders.removeWhere((element) => element == oldOrder);

                    // If the incoming order has 0 as count we'll just remove it
                    if (newOrder.count > 0) {
                      _replaceOrAddOrder(newOrder);
                    }
                  });
                },
              )),
              const GitHubLink(path: "/burritox"),
              SizedBox(
                width: double.infinity,
                height: 75,
                child: TextButton(
                  key: const Key('checkout'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ResultDialog(
                        title: const Text("Orders"),
                        result: orders.toString(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    backgroundColor: Theme.of(context).primaryColor,
                    primary:
                        Theme.of(context).primaryTextTheme.bodyText1?.color,
                  ),
                  child: const Text("Proceed to checkout"),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}
