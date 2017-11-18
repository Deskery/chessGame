package ca.uqac.inf957.chess;

import ca.uqac.inf957.chess.agent.Move;
import ca.uqac.inf957.chess.agent.Player;
import ca.uqac.inf957.chess.piece.*;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Date;

public aspect PlayAspect {

    pointcut callPlay() : call(* Game.play());

    before() : callPlay() {
        String journal = "result.txt";
        PrintWriter out = null;

        try {
            out = new PrintWriter(journal);
            out.close();

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    pointcut callMove(Player player, Move move) : call(* Player.move(Move)) && target(player) && args(move);

    before(Player player, Move move) : callMove(player, move){

        Board board = player.getPlayGround();
        int x0, x1, y0, y1;
        x0 = move.xI;
        y0 = move.yI;
        x1 = move.xF;
        y1 = move.yF;

        if(board.getGrid()[x0][y0].getPiece().getPlayer() == player.getColor() )
        {
            if( (!board.getGrid()[x1][y1].isOccupied()) || ( (board.getGrid()[x1][y1].isOccupied())
                    && ( board.getGrid()[x1][y1].getPiece().getPlayer() != player.getColor() ) ) )
            {
                if (board.getGrid()[x0][y0].getPiece().getClass().equals(Pawn.class))
                {
                    if (player.getColor() == Player.WHITE)
                    {
                        if( ( (x1 == x0) && (y1 == y0+1 )) || ((x1 == x0) && (y1 == y0+2 ) && (y0 == 1))
                                || ((x1 == x0-1) && (y1 == y0+1) && ( board.getGrid()[x1][y1].isOccupied() ) && ( board.getGrid()[x1][y1].getPiece().getPlayer() == Player.BLACK))
                                || ((x1 == x0+1)  && (y1 == y0+1) && ( board.getGrid()[x1][y1].isOccupied() ) && ( board.getGrid()[x1][y1].getPiece().getPlayer() == Player.BLACK) ))
                        {
                            // nothing
                        }
                        else
                            System.err.println(player.getClass().toString() + " : Move not valid");

                    }
                    else if (player.getColor() == Player.BLACK)
                    {
                        if( ((x1 == x0) && (y1 == y0-1 ) ) || ((x1 == x0) && (y1 == y0-2 ) && (y0 == 6))
                                || ((x1 == x0-1) && (y1 == y0-1) && ( board.getGrid()[x1][y1].isOccupied() ) && ( board.getGrid()[x1][y1].getPiece().getPlayer() == Player.WHITE))
                                || ((x1 == x0+1)  && (y1 == y0-1) && ( board.getGrid()[x1][y1].isOccupied() ) && ( board.getGrid()[x1][y1].getPiece().getPlayer() == Player.WHITE) ))
                        {
                           // nothing
                        }
                        else
                            System.err.println(player.getClass().toString() + " : Move not valid");
                    }

                }
                else if (board.getGrid()[x0][y0].getPiece().getClass().equals(Bishop.class)) {
                    if (!checkDiagonal(player, board, x0, y0, x1, y1))
                        System.err.println(player.getClass().toString() + " : Move not valid");
                }
                else if (board.getGrid()[x0][y0].getPiece().getClass().equals(Knight.class))
                {
                    if( ( ( (x1==x0+1) && (y1 == y0+2) ) || ( (x1==x0+2) && (y1 == y0+1) ) || ( (x1==x0+2) && (y1 == y0-1) ) || ( (x1==x0+1) && (y1 == y0-2) ) ||
                            ( (x1==x0-1) && (y1 == y0-2) ) || ( (x1==x0-2) && (y1 == y0-1) ) || ( (x1==x0-2) && (y1 == y0+1) ) || ( (x1==x0-1) && (y1 == y0+2) ) )
                            && ( !(board.getGrid()[x1][y1].isOccupied()) || ( (board.getGrid()[x1][y1].isOccupied()) && ( board.getGrid()[x1][y1].getPiece().getPlayer() != player.getColor() ) ))){

                    }
                    else
                        System.err.println(player.getClass().toString() + " : Move not valid");

                }
                else if (board.getGrid()[x0][y0].getPiece().getClass().equals(Rook.class))
                {
                    if(!checkCross(player, board, x0, y0, x1, y1))
                        System.err.println(player.getClass().toString() + " : Move not valid");
                }
                else if (board.getGrid()[x0][y0].getPiece().getClass().equals(Queen.class))
                {
                    if(!checkCross(player, board, x0, y0, x1, y1) && !checkDiagonal(player, board, x0, y0, x1, y1))
                        System.err.println(player.getClass().toString() + " : Move not valid");
                }
                else if (board.getGrid()[x0][y0].getPiece().getClass().equals(King.class))
                {
                    if(!checkCross(player, board, x0, y0, x1, y1) && !checkDiagonal(player, board, x0, y0, x1, y1))
                        System.err.println(player.getClass().toString() + " : Move not valid");
                }
            }
            else System.err.println(player.getClass().toString() + " : Move not valid : piece");
        }
        else {
            System.err.println(player.getClass().toString() + " : Move not valid (color)");
        }
        //TODO refuse move

    }

    after(Player player, Move move) : callMove(player, move){

        int x0, x1, y0, y1;
        x0 = move.xI;
        y0 = move.yI;
        x1 = move.xF;
        y1 = move.yF;

        Date date = new Date();
        SimpleDateFormat format = new SimpleDateFormat("hh:mm:ss");
        String stringDate = format.format(date);

        String strToAppend = "At " + stringDate + " : the " + player.getColorName() + " player moved his piece from ["
                + x0 + ";" + y0 + "] to [" + x1 + ";" + y1 + "]\n\r";

        String journal = "result.txt";
        File f = new File(journal);

        PrintWriter out = null;

        try {

            if (f.exists() && !f.isDirectory()) {
                out = new PrintWriter(new FileOutputStream(new File(journal), true));
            } else {
                out = new PrintWriter(journal);
            }
            out.append(strToAppend);
            out.append(System.lineSeparator());
            out.close();

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

    }

    private boolean checkDiagonal(Player player, Board board, int x0, int y0, int x1, int y1) {
        boolean isMovePossible = true;

        if ( (Math.abs(x1-x0) == Math.abs(y1-y0) )
                && ( !(board.getGrid()[x1][y1].isOccupied()) || ( (board.getGrid()[x1][y1].isOccupied())
                && ( board.getGrid()[x1][y1].getPiece().getPlayer() != player.getColor() ) ) ) ){
            int xV, yV, xTemp, yTemp;

            if (x1 - x0 > 0)
                xV = 1;
            else
                xV = -1;

            if (y1 - y0 > 0)
                yV = 1;
            else
                yV = -1;

            xTemp = x0 + xV;
            yTemp = y0 + yV;

            while (x1 != xTemp && y1 != yTemp) {

                if (!(board.getGrid()[xTemp][yTemp].isOccupied())) {
                    xTemp += xV;
                    yTemp += yV;
                } else isMovePossible = false;

            }
        }
        else isMovePossible = false ;

        return isMovePossible;
    }

    private boolean checkCross(Player player, Board board, int x0, int y0, int x1, int y1) {
        boolean isMovePossible = true;

        if ( ( (Math.abs(x1-x0) == 0 && Math.abs(y1-y0) != 0) || (Math.abs(x1-x0) != 0 && Math.abs(y1-y0) == 0) )
            && ( !(board.getGrid()[x1][y1].isOccupied()) || ( (board.getGrid()[x1][y1].isOccupied())
                && ( board.getGrid()[x1][y1].getPiece().getPlayer() != player.getColor() ) ) ) ){
            int xV, yV, xTemp, yTemp;

            //si on bouge sur l'axe des y
            if(Math.abs(x1-x0) == 0) {
                xV = 0;

                if (y1 - y0 > 0)
                    yV = 1;
                else
                    yV = -1;
            }
            // si on bouge sur l'axe des x
            else {
                yV = 0;

                if (x1 - x0 > 0)
                    xV = 1;
                else
                    xV = -1;
            }

            xTemp = x0 + xV;
            yTemp = y0 + yV;

            while (x1 != xTemp && y1 != yTemp) {

                if (!(board.getGrid()[xTemp][yTemp].isOccupied())) {
                    xTemp += xV;
                    yTemp += yV;
                } else isMovePossible = false;

            }
        }
        else isMovePossible = false ;

        return isMovePossible;
    }

}
