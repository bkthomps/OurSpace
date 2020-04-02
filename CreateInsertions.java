import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

import static java.nio.file.StandardOpenOption.TRUNCATE_EXISTING;
import static java.nio.file.StandardOpenOption.WRITE;

public class CreateInsertions {

    private static final Path MEMBER = Paths.get("member.csv");
    private static final Path GROUP = Paths.get("group.csv");
    private static final Path POST = Paths.get("post.csv");
    private static final Path COMMENT = Paths.get("comment.csv");
    private static final Path LIKE = Paths.get("like.csv");
    private static final String INSERT = "insert.sql";

    private static final Map<String, String> peopleID = new HashMap<>();
    private static final Set<String> posts = new HashSet<>();
    private static final Set<String> postComments = new HashSet<>();
    private static int replyID;

    public static void main(String[] args) throws IOException {
        var file = load();
        save(file);
    }

    private static List<String> load() throws IOException {
        var list = new ArrayList<String>();
        addHeader(list);
        addSex(list);
        addPeople(list);
        addGroups(list);
        addGroupAdmin(list);
        addFollowingFriends(list);
        addFollowingGroups(list);
        addPost(list);
        addPostComment(list);
        addCommentReply(list);
        addReactType(list);
        addReact(list);
        return list;
    }

    private static void addHeader(List<String> list) {
        list.add("USE our_space;");
        list.add("");
    }

    private static void addSex(List<String> list) {
        list.add("INSERT INTO sex VALUES (1, 'Male'),");
        list.add("    (2, 'Female'),");
        list.add("    (3, 'Other');");
        list.add("");
    }

    private static void addPeople(List<String> list) throws IOException {
        boolean isSubsequent = false;
        String line;
        var reader = getReader(MEMBER);
        var people = new HashSet<String>();
        var emails = new HashMap<String, Integer>();
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",");
            var groupID = attributes[0];
            var personID = attributes[1];
            var personName = attributes[2];
            if (!people.contains(personID)) {
                var names = personName.split(" ");
                if (names.length < 2) {
                    throw new IllegalStateException("Less than two names");
                }
                var firstName = names[0];
                var lastName = names[names.length - 1];
                int sexID = generateSexID();
                var emailBase = firstName.toLowerCase() + '.' + lastName.toLowerCase();
                String email;
                if (!emails.containsKey(emailBase)) {
                    email = emailBase + "@gmail.com";
                    emails.put(emailBase, 1);
                } else {
                    int value = emails.get(emailBase);
                    email = emailBase + value + "@gmail.com";
                    emails.put(emailBase, value + 1);
                }
                var passcode = generatePassword();
                peopleID.put(personID, groupID);
                String insert;
                if (!isSubsequent) {
                    insert = String.format("INSERT INTO person VALUES (%s, '%s', '%s', %s, '%s', '%s'),",
                            personID, firstName, lastName, sexID, email, passcode);
                    isSubsequent = true;
                } else {
                    insert = String.format("    (%s, '%s', '%s', %s, '%s', '%s'),",
                            personID, firstName, lastName, sexID, email, passcode);
                }
                list.add(insert);
                people.add(personID);
            }
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static int generateSexID() {
        int sexID;
        double random = Math.random();
        double genderBinaryProportion = 1 - 1.0 / 200;
        if (random < genderBinaryProportion / 2) {
            sexID = 1;
        } else if (random < genderBinaryProportion) {
            sexID = 2;
        } else {
            sexID = 3;
        }
        return sexID;
    }

    private static String generatePassword() {
        var passcode = new StringBuilder();
        int length = (int) ((24 - 8) * Math.random() + 8);
        for (int i = 0; i < length; i++) {
            char letter = (char) (26 * Math.random() + 97);
            passcode.append(letter);
        }
        return passcode.toString();
    }

    private static void addGroups(List<String> list) throws IOException {
        boolean isSubsequent = false;
        String line;
        var reader = getReader(GROUP);
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",");
            var groupID = attributes[0];
            var groupName = attributes[1];
            String insert;
            if (!isSubsequent) {
                insert = String.format("INSERT INTO groups VALUES (%s, '%s'),", groupID, groupName);
                isSubsequent = true;
            } else {
                insert = String.format("    (%s, '%s'),", groupID, groupName);
            }
            list.add(insert);
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static void addGroupAdmin(List<String> list) {
        boolean isSubsequent = false;
        int groupCount = 5;
        int addingAverage = (int) (groupCount * 10 * Math.random());
        var entrySet = peopleID.entrySet();
        var keys = new String[entrySet.size()];
        var values = new String[keys.length];
        int i = 0;
        for (var entry : entrySet) {
            keys[i] = entry.getKey();
            values[i] = entry.getValue();
            i++;
        }
        int count = 0;
        var entries = new HashSet<String>();
        var set = new HashSet<String>();
        while (set.size() != groupCount && count < addingAverage) {
            int index = (int) (keys.length * Math.random());
            var personID = keys[index];
            var groupID = values[index];
            if (set.contains(personID + '_' + groupID)) {
                continue;
            }
            set.add(groupID);
            entries.add(personID + '_' + groupID);
            count++;
            String insert;
            if (!isSubsequent) {
                insert = String.format("INSERT INTO group_admin VALUES (%s, '%s'),", groupID, personID);
                isSubsequent = true;
            } else {
                insert = String.format("    (%s, '%s'),", groupID, personID);
            }
            list.add(insert);
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static void addFollowingFriends(List<String> list) throws IOException {
        boolean isSubsequent = false;
        String line;
        var reader = getReader(MEMBER);
        var uniquePeople = new HashSet<String>();
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",");
            uniquePeople.add(attributes[1]);
        }
        var people = new ArrayList<>(uniquePeople);
        for (var personID : people) {
            var existing = new HashSet<String>();
            existing.add(personID);
            int friendCount = (int) (50 * Math.random());
            for (int i = 0; i < friendCount; i++) {
                int friendIndex = (int) (people.size() * Math.random());
                var friendID = people.get(friendIndex);
                if (!existing.contains(friendID)) {
                    String insert;
                    if (!isSubsequent) {
                        insert = String.format("INSERT INTO following_friends VALUES (%s, %s),", personID, friendID);
                        isSubsequent = true;
                    } else {
                        insert = String.format("    (%s, %s),", personID, friendID);
                    }
                    list.add(insert);
                    existing.add(friendID);
                }
            }
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static void addFollowingGroups(List<String> list) throws IOException {
        boolean isSubsequent = false;
        String line;
        var reader = getReader(MEMBER);
        var combination = new HashSet<String>();
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",");
            var groupID = attributes[0];
            var personID = attributes[1];
            if (!combination.contains(personID + "_" + groupID)) {
                combination.add(personID + "_" + groupID);
                String insert;
                if (!isSubsequent) {
                    insert = String.format("INSERT INTO following_groups VALUES (%s, %s),", personID, groupID);
                    isSubsequent = true;
                } else {
                    insert = String.format("    (%s, %s),", personID, groupID);
                }
                list.add(insert);
            }
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static void addPost(List<String> list) throws IOException {
        boolean isSubsequent = false;
        String line;
        var reader = getReader(POST);
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",", -1);
            var groupID = attributes[0];
            var postID = attributes[1].split("_")[1];
            var personID = attributes[2];
            var timeStamp = attributes[4];
            var shares = attributes[5];
            var content = attributes[7].replace("{COMMA}", ",").replace("{APOST}", "\\'").replace("{RET}", " ");
            int likes = (int) Double.parseDouble(attributes[8].isEmpty() ? "0.0" : attributes[8]);
            if (!posts.contains(postID) && peopleID.containsKey(personID)) {
                posts.add(postID);
                String insert;
                if (!isSubsequent) {
                    insert = String.format("INSERT INTO post VALUES (%s, '%s', %s, %s, '%s', %d, %s),",
                            postID, content, personID, groupID, timeStamp, likes, shares);
                    isSubsequent = true;
                } else {
                    insert = String.format("    (%s, '%s', %s, %s, '%s', %d, %s),",
                            postID, content, personID, groupID, timeStamp, likes, shares);
                }
                list.add(insert);
            }
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static void addPostComment(List<String> list) throws IOException {
        boolean isSubsequent = false;
        int count = 0;
        String line;
        var reader = getReader(COMMENT);
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",", -1);
            var groupID = attributes[0];
            var postID = attributes[1].split("_")[1];
            var commentID = attributes[2];
            var timeStamp = attributes[3];
            var personID = attributes[4];
            var replyPersonID = attributes[6];
            var content = attributes[7].replace("{COMMA}", ",").replace("{APOST}", "\\'").replace("{RET}", " ");
            if (replyPersonID.isEmpty() && !postComments.contains(commentID)
                    && posts.contains(postID) && peopleID.containsKey(personID)) {
                if (posts.contains(commentID)) {
                    throw new IllegalStateException("Comment ID intersects with post ID");
                }
                postComments.add(commentID);
                String insert;
                count++;
                if (!isSubsequent) {
                    insert = String.format("INSERT INTO post_comment VALUES (%s, '%s', %s, %s, '%s', %s),",
                            commentID, content, personID, groupID, timeStamp, postID);
                    isSubsequent = true;
                } else if (count % 20_000 == 0) {
                    var last = list.remove(list.size() - 1);
                    last = last.substring(0, last.length() - 1) + ';';
                    list.add(last);
                    insert = String.format("INSERT INTO post_comment VALUES (%s, '%s', %s, %s, '%s', %s),",
                            commentID, content, personID, groupID, timeStamp, postID);
                } else {
                    insert = String.format("    (%s, '%s', %s, %s, '%s', %s),",
                            commentID, content, personID, groupID, timeStamp, postID);
                }
                list.add(insert);
            }
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static void addCommentReply(List<String> list) throws IOException {
        boolean isSubsequent = false;
        String line;
        var reader = getReader(COMMENT);
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",", -1);
            var groupID = attributes[0];
            var postID = attributes[1].split("_")[1];
            var commentID = attributes[2];
            var timeStamp = attributes[3];
            var personID = attributes[6];
            var content = attributes[7].replace("{COMMA}", ",").replace("{APOST}", "\\'").replace("{RET}", " ");
            if (!personID.isEmpty() && posts.contains(postID)
                    && postComments.contains(commentID) && peopleID.containsKey(personID)) {
                replyID++;
                if (posts.contains("" + replyID)) {
                    throw new IllegalStateException("Reply ID intersects with post ID");
                }
                if (postComments.contains("" + replyID)) {
                    throw new IllegalStateException("Reply ID intersects with comment ID");
                }
                String insert;
                if (!isSubsequent) {
                    insert = String.format("INSERT INTO comment_reply VALUES (%d, '%s', %s, %s, '%s', %s, %s),",
                            replyID, content, personID, groupID, timeStamp, postID, commentID);
                    isSubsequent = true;
                } else {
                    insert = String.format("    (%d, '%s', %s, %s, '%s', %s, %s),",
                            replyID, content, personID, groupID, timeStamp, postID, commentID);
                }
                list.add(insert);
            }
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static void addReactType(List<String> list) {
        list.add("INSERT INTO react_type VALUES (1, 'LIKE'),");
        list.add("    (2, 'LOVE'),");
        list.add("    (3, 'HAHA'),");
        list.add("    (4, 'WOW'),");
        list.add("    (5, 'SAD'),");
        list.add("    (6, 'ANGRY');");
        list.add("");
    }

    private static void addReact(List<String> list) throws IOException {
        boolean isSubsequent = false;
        String line;
        var reader = getReader(LIKE);
        var reactedCombination = new HashSet<String>();
        while ((line = reader.readLine()) != null) {
            var attributes = line.split(",");
            var postID = attributes[1].split("_")[1];
            var commentID = attributes[2];
            var response = attributes[3];
            var reactingPersonID = attributes[4];
            int responseCode = getResponseCode(response);
            // Only posts and comments have reactions; not comments to comments
            var contentID = commentID.equals("x") ? postID : commentID;
            if (reactedCombination.contains(reactingPersonID + '_' + contentID)
                    || !peopleID.containsKey(reactingPersonID) || !posts.contains(postID)) {
                continue;
            }
            reactedCombination.add(reactingPersonID + '_' + contentID);
            String insert;
            if (!isSubsequent) {
                insert = String.format("INSERT INTO content_react VALUES (%s, %s, %s),",
                        contentID, reactingPersonID, responseCode);
                isSubsequent = true;
            } else {
                insert = String.format("    (%s, %s, %s),",
                        contentID, reactingPersonID, responseCode);
            }
            list.add(insert);
        }
        var last = list.remove(list.size() - 1);
        last = last.substring(0, last.length() - 1) + ';';
        list.add(last);
        list.add("");
    }

    private static int getResponseCode(String response) {
        switch (response) {
            case "LIKE":
            case "LIKES":
            case "THANKFUL":
                return 1;
            case "LOVE":
                return 2;
            case "HAHA":
                return 3;
            case "WOW":
                return 4;
            case "SAD":
                return 5;
            case "ANGRY":
                return 6;
            default:
                throw new IllegalStateException("Bad reaction type: " + response);
        }
    }

    private static BufferedReader getReader(Path path) throws IOException {
        var reader = new BufferedReader(new InputStreamReader(Files.newInputStream(path)));
        reader.readLine();
        return reader;
    }

    private static void save(List<String> list) throws IOException {
        var sb = new StringBuilder();
        for (var str : list) {
            sb.append(str);
            sb.append('\n');
        }
        var save = new File(INSERT);
        if (!save.exists()) {
            Files.createFile(Paths.get(INSERT));
        }
        byte[] data = sb.toString().getBytes();
        var out = new BufferedOutputStream(Files.newOutputStream(Paths.get(INSERT), WRITE, TRUNCATE_EXISTING));
        out.write(data, 0, data.length);
    }
}
