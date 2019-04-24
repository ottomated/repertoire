import 'package:repertoire/io/repertoire.dart';
import 'package:repertoire/io/dance.dart';
import 'package:repertoire/io/single_dancer_list.dart';
import 'package:repertoire/io/partner_dancer_list.dart';
import 'package:repertoire/io/dancer.dart';
import 'package:repertoire/io/piece.dart';
import 'package:repertoire/io/costume.dart';
import 'dart:io';
import 'dart:convert';
import 'package:repertoire/io/song.dart';
import 'package:repertoire/io/timestamp.dart';
import 'dart:typed_data';
import 'package:repertoire/io/serialization.dart';

void main(List<String> args) {
  print(utf8.encode("").length);
  File f = File(args[0]);
  if (args[1] == 'w') {
    Repertoire r = Repertoire(
      name: "Forgatos",
      dances: [
        Dance(
          name: "Marossapataki",
          description: "Description of the dance",
          song: Song(
              name: "Song",
              description: "This is the description of this song",
              audio: Uint8List.fromList(File('song.mp3').readAsBytesSync()),
              timestamps: [
                Timestamp(name: "Vergunk", time: Duration(seconds: 40)),
                Timestamp(name: "Couples", time: Duration(seconds: 120)),
              ]),
          costumes: [
            Costume(
              name: 'Costume 1',
              description: 'Women\'s costume for part 1 of dance',
              dancerPart: DancerPart.follow,
              pieces: [
                Piece(
                  name: 'Skirt',
                  description: 'piece 1',
                  image: Uint8List.fromList(File('image.png').readAsBytesSync()),
                ),
                Piece(
                  name: 'Shoes',
                  description: 'piece 2',
                  image: Uint8List.fromList(File('profile.png').readAsBytesSync()),
                ),
              ],
            ),
          ],
          dancers: /*SingleDancerList(
            dancers: [
              Dancer(
                name: "Dancer 1",
                description: "1 is a cool person",
                part: DancerPart.any,
              ),
              Dancer(
                name: "Dancer 2",
                description: "2 is a cool person as well",
                part: DancerPart.follow,
              ),
            ],
          ),*/

          PartnerDancerList(
            couples: [
              Couple(
                Dancer(
                  name: "Dancer 1",
                  description: "1 is a cool person",
                  part: DancerPart.any,
                ),
                Dancer(
                  name: "Dancer 2",
                  description: "2 is a cool person as well",
                  part: DancerPart.follow,
                ),
              ),
              Couple.empty(
                first: Dancer(
                  name: "Dancer 3",
                  description: "3 is not cool though",
                  part: DancerPart.lead,
                ),
              ),
              Couple.empty(
                second: Dancer(
                  name: "Dancer 4",
                  description: "alone",
                  part: DancerPart.lead,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    r.serialize(RepSink(f.openWrite()));
  } else {
    var bytes = ByteScanner.fromList(f.readAsBytesSync());
    Repertoire r = Repertoire.deserialize(bytes);
    print(r);
  }
}
