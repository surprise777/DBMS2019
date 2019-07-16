import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
//import java.util.HashMap;
import java.util.Set;
//import java.util.HashSet;

public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
            return true;
        } catch (SQLException m) {
            System.err.println("SQL Exception. " + "<message>: " + m.getMessage());
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.close();
            return true;
        } catch (SQLException m) {
            System.err.println("SQL Exception. " + "<message>: " + m.getMessage());
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        ElectionCabinetResult r = new ElectionCabinetResult(new ArrayList<Integer>(), new ArrayList<Integer>());
        try {
            String drop = "DROP VIEW " +
                    "IF EXISTS Tempt CASCADE;";
            PreparedStatement dropState = connection.prepareStatement(drop);
            dropState.execute();

            String countryQ = "SELECT id " +
                    "FROM country " +
                    "WHERE name = ?;";
            PreparedStatement countryStatement = connection.prepareStatement(countryQ);
            countryStatement.setString(1, countryName);
            ResultSet countryR = countryStatement.executeQuery();
            countryR.next();

            int countryID = countryR.getInt("id");
            String electionQ = "CREATE VIEW Tempt AS " +
                    "SELECT id, e_date, e_type AS type " +
                    "FROM election " +
                    "WHERE country_id = " + Integer.toString(countryID) + " " +
                    "ORDER BY e_date DESC;";
            PreparedStatement electionStatement = connection.prepareStatement(electionQ);
            electionStatement.execute();

            String searchElecQ = "SELECT * FROM Tempt;";
            PreparedStatement searchStatement = connection.prepareStatement(searchElecQ);
            ResultSet searchElecR = searchStatement.executeQuery();
            ArrayList<Integer> idList = new ArrayList<Integer>();
            while (searchElecR.next()) {
                int newId = searchElecR.getInt("id");
                idList.add(newId);
            }
            for (int x = 0; x < idList.size(); x++) {
                int index = idList.get(x);
                String idQ = "SELECT id " +
                        "FROM cabinet " +
                        "WHERE election_id = ? " +
                        "ORDER BY start_date;";
                PreparedStatement idStatement = connection.prepareStatement(idQ);
                idStatement.setInt(1, index);
                ResultSet idR = idStatement.executeQuery();
                while (idR.next()) {
                    int cabinetsID = idR.getInt("id");
                    r.elections.add(index);
                    r.cabinets.add(cabinetsID);
                }
            }
            return r;
        } catch (SQLException se) {
            System.err.println("SQL Exception. " + "<message>: " + se.getMessage());
            return null;
        }
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        Connection c = this.connection;
        PreparedStatement ps, ps1;
        ResultSet r, r1;
        String query, query1;
        String inputPresident = new String("");
        String comparedPresident;
        float jSimilar;
        List<Integer> similarP = new ArrayList<Integer>();

        try {
            query = "SELECT id, description, comment " +
                    "FROM politician_president " +
                    "WHERE id = ?;";
            ps = c.prepareStatement(query);
            ps.setInt(1, politicianName);
            r = ps.executeQuery();
            while (r.next()) {
                inputPresident = r.getString("description") + " " + r.getString("comment");
            }

            query1 = "SELECT id, description, comment " +
                    "FROM politician_president " +
                    "WHERE id <> " + Integer.toString(politicianName) + ";";
            ps1 = c.prepareStatement(query1);
            r1 = ps1.executeQuery();

            while (r1.next()) {
                comparedPresident = r1.getString("description") + " " + r1.getString("comment");
                jSimilar = (float) similarity(inputPresident, comparedPresident);
                if (jSimilar >= threshold) {
                    int i = r1.getInt("id");
                    if (i != politicianName) {
                        similarP.add(i);
                    }
                }
            }
        } catch (SQLException se) {
            System.err.println("SQL Exception. " + "<message>: " + se.getMessage());
        }
        return similarP;

    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
        try {
            Assignment2 test1 = new Assignment2();
            boolean t = test1.connectDB("jdbc:postgresql://localhost:5432/csc343h-dianeh",
                    "dianeh", "");
            test1.electionSequence("Canada");
            boolean t0 = test1.disconnectDB();
        } catch (ClassNotFoundException ce) {
            System.out.println("Failed to find the JDBC Driver.");
        }
    }

}

