// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util';
import 'package:app2/services.dart/chain.dart';
import 'package:app2/widgets/atncontract.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

String owner;
Web3Provider web3user;
bool data = false;
Client httpclient;
bool merge = false;
Human us3r;
String sursa = '0x18A4d5A9039fd15A6576896cd7B445f9e4F3cff1';

class Web3 extends ChangeNotifier {
  bool hopa = false;
  void changeHopa(adresa) async {
    await promiseToFuture(web3user.getBalance(owner));
  }

  List<String> sourceAbi = [
    'function allProjects() view returns(address[])',
    'function projects(address) view returns (address)',
    'function users(address) view returns (address)',
    'function createUser() returns(address)'
  ];

  List<String> userAbi = [
    'function balanceATN() view returns (uint256)',
    'function getAssets() view returns (tuple(address,uint256)[])',
  ];

  List<String> token = ['function approve'];
  List<String> projectAbi = ['function details() view returns(string[])'];

  void web3sign() async {
    merge = true;
    await promiseToFuture(
        ethereum.request(RequestParams(method: 'eth_requestAccounts')));
    var se = ethereum.selectedAddress;
    web3user = Web3Provider(ethereum);
    var catAre =
        await promiseToFuture(web3user.getBalance(ethereum.selectedAddress));
    owner = se;
    var sourceContract = Contract(sursa, sourceAbi, web3user);
    var first = await callMethod(sourceContract, 'users', [se]);
    var ponse = await promiseToFuture(first);
    var assets = <String, double>{};
    dynamic tonse;
    if (!ponse.toString().contains('000000')) {
      var userContract = Contract(ponse.toString(), userAbi, web3user);
      var firstAndAHaldf = await callMethod(userContract, 'balanceATN', []);
      tonse = await promiseToFuture(firstAndAHaldf);
      var second = await callMethod(userContract, 'getAssets', []);
      var donse = await promiseToFuture(second);
      for (var asset in donse) {
        // ignore: avoid_dynamic_calls
        assets[asset[0].toString()] = double.parse(asset[1].toString());
      }
    }
    us3r = Human(address: se, web3: web3user);
    us3r.balance = EtherAmount.fromUnitAndValue(
        EtherUnit.wei, BigInt.parse(catAre.toString()));
    if (!ponse.toString().contains('000000')) {
      var uc =
          UserContract(address: ponse.toString(), user: us3r, assets: assets);
      // ignore: cascade_invocations
      uc.valoare = EtherAmount.fromUnitAndValue(
          EtherUnit.wei, BigInt.parse(tonse.toString()));
      us3r.contract = uc;
    }

    merge = false;
  }
}
