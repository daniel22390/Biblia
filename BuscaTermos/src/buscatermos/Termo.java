package buscatermos;

/**
 * Classe que manipula os termos
 * @author Daniel Gomes
 */
public class Termo {
    
    private String termo;
    
    private String sinonimo;
    
    private String antonimo;

    /**
     * Get the value of antonimo
     *
     * @return the value of antonimo
     */
    public String getAntonimo() {
        return antonimo;
    }

    /**
     * Set the value of antonimo
     *
     * @param antonimo new value of antonimo
     */
    public void setAntonimo(String antonimo) {
        this.antonimo = antonimo;
    }


    /**
     * Get the value of sinonimo
     *
     * @return the value of sinonimo
     */
    public String getSinonimo() {
        return sinonimo;
    }

    /**
     * Set the value of sinonimo
     *
     * @param sinonimo new value of sinonimo
     */
    public void setSinonimo(String sinonimo) {
        this.sinonimo = sinonimo;
    }


    /**
     * Get the value of termo
     *
     * @return the value of termo
     */
    public String getTermo() {
        return termo;
    }

    /**
     * Set the value of termo
     *
     * @param termo new value of termo
     */
    public void setTermo(String termo) {
        this.termo = termo;
    }

}
